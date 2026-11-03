$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $repo "checksums\sha256-manifest.csv"
$entries = @(Import-Csv -LiteralPath $manifest)

if ($entries.Count -ne 5) {
    throw "Expected 5 manifest entries; found $($entries.Count)."
}

$expectedPaths = @(1..5 | ForEach-Object {
    "data/synthetic/hartley-demo-{0:D2}.txt" -f $_
})

$actualPaths = @($entries | Select-Object -ExpandProperty RelativePath)
$uniquePaths = @($actualPaths | Sort-Object -Unique)

if ($uniquePaths.Count -ne 5) {
    throw "Manifest contains duplicate file paths."
}

if (@(Compare-Object $expectedPaths $actualPaths).Count -gt 0) {
    throw "Manifest does not list the five expected demonstration files."
}

$results = foreach ($entry in $entries) {
    if ($entry.Algorithm -ne "SHA256" -or $entry.SHA256 -notmatch '^[0-9A-Fa-f]{64}$') {
        throw "Invalid algorithm or hash for $($entry.RelativePath)."
    }

    $filePath = Join-Path $repo $entry.RelativePath

    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        [PSCustomObject]@{
            File        = $entry.RelativePath
            SizeMatches = $false
            HashMatches = $false
            Status      = "MISSING"
        }
    } else {
        $file = Get-Item -LiteralPath $filePath
        $hash = Get-FileHash -LiteralPath $filePath -Algorithm SHA256
        $sizeMatches = ($file.Length -eq [long]$entry.SizeBytes)
        $hashMatches = ($hash.Hash -eq $entry.SHA256)

        $status = "FAIL"
        if ($sizeMatches -and $hashMatches) {
            $status = "PASS"
        }

        [PSCustomObject]@{
            File        = $entry.RelativePath
            SizeMatches = $sizeMatches
            HashMatches = $hashMatches
            Status      = $status
        }
    }
}

$results | Format-Table -AutoSize | Out-Host

$failures = @($results | Where-Object { $_.Status -ne "PASS" })

if ($failures.Count -gt 0) {
    throw "$($failures.Count) file(s) failed verification. Keep the baseline unchanged."
}

Write-Host "PASS: All 5 files match the saved checksum baseline."