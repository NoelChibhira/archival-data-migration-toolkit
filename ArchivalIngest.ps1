param (
    [string]$SourceDir,
    [string]$ReportPath
)
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " RUNNING ARCHIVAL INTAKE & SIP PREPARATION UTILITY" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Establish the Quarantine directory paths safely
$QuarantinePath = Join-Path $SourceDir "Quarantine_Hold"
if (-not (Test-Path $QuarantinePath)) { New-Item -ItemType Directory -Path $QuarantinePath -Force | Out-Null }

# Discover files while excluding the active quarantine subdirectory
$TargetFiles = Get-ChildItem -Path $SourceDir -File -Recurse | Where-Object { $_.FullName -notlike "*Quarantine_Hold*" }
$TotalFiles = $TargetFiles.Count
Write-Host "Found $TotalFiles files to process." -ForegroundColor Green

$ManifestReport = [System.Collections.Generic.List[PSObject]]::new()

foreach ($File in $TargetFiles) {
    # Initialize baseline validation tracking parameters
    $MD5Checksum    = "PENDING"
    $SHA256Checksum = "PENDING"
    $ProcessingTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $FixityStatus   = "Pass"
    $IngestNotes    = "Baseline fixity values recorded for later integrity verification."

    # Compute the relative folder path dynamically (Case-Insensitive Regex)
    $CleanSourceDir = [regex]::Escape($SourceDir.TrimEnd("\"))
    $RelativePath   = $File.DirectoryName -replace "^$CleanSourceDir", ""
    if ([string]::IsNullOrEmpty($RelativePath)) { $RelativePath = "\" }

    # 1. Isolated Checksum Generation Layer with Error Isolation
    try {
        $MD5Checksum    = (Get-FileHash -Path $File.FullName -Algorithm MD5 -ErrorAction Stop).Hash
        $SHA256Checksum = (Get-FileHash -Path $File.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch {
        $MD5Checksum    = "ERROR"
        $SHA256Checksum = "ERROR"
        $FixityStatus   = "Review"
        $IngestNotes    = "ERROR: Hashing engine failed due to file-lock or read permission block."
    }

    # 2. Ingestion Validation Constraint Check (Zero-Byte Evaluation)
    if ($File.Length -eq 0) {
        $FixityStatus = "Fail"
        $IngestNotes  = "Zero-byte empty file detected; isolated and transferred to quarantine branch."
        
        # Prevent Quarantine Name Collisions by embedding a unique GUID prefix
        $UniquePrefix = [Guid]::NewGuid().ToString().Substring(0,8)
        $QuarantineFileName = "$UniquePrefix`_$($File.Name)"
        $DestinationFileTarget = Join-Path $QuarantinePath $QuarantineFileName
        
        # Isolated File Move Operation with targeted exception catch layer
        try {
            Move-Item -Path $File.FullName -Destination $DestinationFileTarget -Force -ErrorAction Stop
        } catch {
            $FixityStatus = "Error"
            $IngestNotes  = "CRITICAL: Zero-byte file identified, but physical file move operation was locked or aborted."
        }
    }

    # 3. Add file to the manifest tracking report
    $ManifestReport.Add([PSCustomObject]@{
        "DigitalAssetID"       = [Guid]::NewGuid().ToString()
        "OriginalFileName"     = $File.Name
        "RelativeFolderPath"   = $RelativePath
        "FileExtension"        = $File.Extension.ToUpper()
        "FileSize_Bytes"       = $File.Length
        "BaselineHash_MD5"     = $MD5Checksum
        "BaselineHash_SHA256"  = $SHA256Checksum
        "ProcessingTimestamp"  = $ProcessingTime
        "IntakeStatus"         = $FixityStatus
        "AdministrativeNotes"  = $IngestNotes
    })
}

# Export the final complete manifest package receipt to CSV
$ManifestReport | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "Intake protocol completed safely. Review manifest file layout at: $ReportPath" -ForegroundColor Green
