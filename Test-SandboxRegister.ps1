<#
.SYNOPSIS
Validates an exported technical document register.

.DESCRIPTION
Checks record count, required metadata, duplicate Document IDs
and the configured Document ID pattern.

Writes reports to a new run folder.
Does not modify the input CSV or update Airtable.

Results are metadata checks only, not approval for release,
engineering validation or legal compliance assessments.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputCsv,

    [int]$ExpectedCount = 1000,

    [string]$OutputRoot = ".",

    [string]$IdPattern = "^SYN-PRO-\d{5}$"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredFields = @(
    "Document ID",
    "Document Title",
    "Document Type",
    "Discipline",
    "Project / Programme",
    "Revision",
    "Document Status",
    "Security Classification"
)

try {
    # Validate input and configuration.
    if (-not (Test-Path -LiteralPath $InputCsv -PathType Leaf)) {
        throw "CSV file not found: $InputCsv"
    }

    if ($ExpectedCount -lt 1) {
        throw "ExpectedCount must be greater than zero."
    }

    # Validate the regular expression before processing.
    $idRegex = [regex]::new($IdPattern)

    $sourcePath = (Resolve-Path -LiteralPath $InputCsv).Path

    $sourceHash = (
        Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256
    ).Hash

    $records = @(
        Import-Csv -LiteralPath $sourcePath -Encoding UTF8
    )

    if ($records.Count -eq 0) {
        throw "The CSV contains no data records."
    }

    # Check that the required columns exist.
    $headers = @($records[0].PSObject.Properties.Name)

    $missingHeaders = @(
        $requiredFields |
            Where-Object { $headers -notcontains $_ }
    )

    if ($missingHeaders.Count -gt 0) {
        throw (
            "Required CSV columns missing: " +
            ($missingHeaders -join ", ")
        )
    }

    # Count IDs using trimmed, case-insensitive comparisons.
    $idCounts = @{}

    foreach ($record in $records) {
        $id = ([string]$record.'Document ID').Trim()

        if (-not [string]::IsNullOrWhiteSpace($id)) {
            if ($idCounts.ContainsKey($id)) {
                $idCounts[$id]++
            }
            else {
                $idCounts[$id] = 1
            }
        }
    }

    $runId = [guid]::NewGuid().ToString()
    $runTimeUtc = [DateTime]::UtcNow.ToString("o")

    $results = [System.Collections.Generic.List[object]]::new()
    $rowNumber = 0

    foreach ($record in $records) {
        $rowNumber++

        $issues = [System.Collections.Generic.List[string]]::new()

        $rawId = [string]$record.'Document ID'
        $id = $rawId.Trim()

        # Check mandatory metadata.
        foreach ($field in $requiredFields) {
            $value = [string]$record.$field

            if ([string]::IsNullOrWhiteSpace($value)) {
                $issues.Add("Missing required value: $field")
            }
        }

        # Check populated Document IDs.
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            if ($rawId -cne $id) {
                $issues.Add(
                    "Document ID has leading or trailing whitespace"
                )
            }

            if (-not $idRegex.IsMatch($id)) {
                $issues.Add(
                    "Document ID does not match configured pattern"
                )
            }

            if ($idCounts[$id] -gt 1) {
                $issues.Add("Duplicate Document ID")
            }
        }

        $status = if ($issues.Count -eq 0) {
            "Passed configured checks"
        }
        else {
            "Requires review"
        }

        $results.Add(
            [pscustomobject][ordered]@{
                RunId                  = $runId
                RunTimeUtc             = $runTimeUtc
                DataRowNumber          = $rowNumber
                DocumentID             = $rawId
                DocumentTitle          = [string]$record.'Document Title'
                ValidationStatus       = $status
                IssueCount             = $issues.Count
                Issues                 = $issues -join "; "
            }
        )
    }

    # Create a unique folder for this run.
    $folderName = "run-{0}-{1}" -f (
        [DateTime]::UtcNow.ToString("yyyyMMdd-HHmmss")
    ), $runId

    $runFolder = Join-Path $OutputRoot $folderName

    New-Item -ItemType Directory -Path $runFolder -Force |
        Out-Null

    $reportPath = Join-Path $runFolder "validation-report.csv"

    $results |
        Export-Csv -LiteralPath $reportPath `
            -NoTypeInformation -Encoding UTF8

    $exceptions = @(
        $results |
            Where-Object { $_.IssueCount -gt 0 }
    )

    if ($exceptions.Count -gt 0) {
        $exceptionsPath = Join-Path $runFolder "exceptions.csv"

        $exceptions |
            Export-Csv -LiteralPath $exceptionsPath `
                -NoTypeInformation -Encoding UTF8
    }

    $countMatches = $records.Count -eq $ExpectedCount

    $overallOutcome = if (
        $countMatches -and $exceptions.Count -eq 0
    ) {
        "Passed configured checks"
    }
    else {
        "Requires review"
    }

    $summary = [ordered]@{
        RunId                  = $runId
        RunTimeUtc             = $runTimeUtc
        InputFile              = $sourcePath
        InputSha256            = $sourceHash
        ExpectedRecordCount    = $ExpectedCount
        ActualRecordCount      = $records.Count
        RecordCountMatches     = $countMatches
        RecordsPassingChecks   = $records.Count - $exceptions.Count
        RecordsRequiringReview = $exceptions.Count
        RequiredFields         = $requiredFields
        DocumentIdPattern      = $IdPattern
        DuplicateComparison    = "Trimmed and case-insensitive"
        ValidationScope        = "Exported register metadata only"
        OverallOutcome         = $overallOutcome
    }

    $summaryPath = Join-Path $runFolder "run-summary.json"

    $summary |
        ConvertTo-Json -Depth 5 |
        Set-Content -LiteralPath $summaryPath -Encoding UTF8

    Write-Host ""
    Write-Host "VALIDATION COMPLETED"
    Write-Host "--------------------"
    Write-Host "Records checked: $($records.Count)"
    Write-Host "Expected records: $ExpectedCount"
    Write-Host "Record count matches: $countMatches"
    Write-Host (
        "Records passing checks: " +
        ($records.Count - $exceptions.Count)
    )
    Write-Host "Records requiring review: $($exceptions.Count)"
    Write-Host "Overall outcome: $overallOutcome"
    Write-Host "Reports saved to: $runFolder"
    Write-Host ""
}
catch {
    Write-Error (
        "Validation stopped: " + $_.Exception.Message
    )
}