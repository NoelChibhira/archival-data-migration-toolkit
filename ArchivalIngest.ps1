param (
    [string]$SourceDir,
    [string]$ReportPath
)
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " RUNNING UPGRADED INGEST & QUARANTINE PROTOCOL" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Create a secure quarantine folder inside the source directory
$QuarantinePath = Join-Path $SourceDir "Quarantine_Hold"
if (-not (Test-Path $QuarantinePath)) { New-Item -ItemType Directory -Path $QuarantinePath -Force | Out-Null }

# FIX: Changed Where-Content to Where-Object
$TargetFiles = Get-ChildItem -Path $SourceDir -File -Recurse | Where-Object { $_.FullName -notlike "*Quarantine_Hold*" }
$TotalFiles = $TargetFiles.Count
Write-Host "Found $TotalFiles digital assets to process." -ForegroundColor Green

$ManifestReport = [System.Collections.Generic.List[PSObject]]::new()

foreach ($File in $TargetFiles) {
    try { $Checksum = (Get-FileHash -Path $File.FullName -Algorithm MD5).Hash } catch { $Checksum = "ERROR" }
    
    # Run the appraisal checks
    if ($File.Length -eq 0) {
        $Status = "Fail"
        $Notes = "CRITICAL: Zero-byte file isolated and moved to Quarantine."
        
        # Safely move the corrupt/empty file out of the active collection
        Move-Item -Path $File.FullName -Destination $QuarantinePath -Force
    } else {
        $Status = "Pass"
        $Notes = "File verified for preservation package."
    }

    $ManifestReport.Add([PSCustomObject]@{
        "DigitalAssetID"      = [Guid]::NewGuid().ToString()
        "OriginalFileName"    = $File.Name
        "RelativePath"        = $File.FullName.Replace($SourceDir, "")
        "FileExtension"       = $File.Extension.ToUpper()
        "FileSize_Bytes"      = $File.Length
        "IngestChecksum_MD5"  = $Checksum
        "DateDigitised"       = $File.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
        "FixityStatus"        = $Status
        "IngestNotes"         = $Notes
    })
}
$ManifestReport | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "Ingest completed! Manifest saved. Any failed assets have been physically isolated." -ForegroundColor Green
