# Verification record: 2026-11-03

## Scope

Five synthetic TXT files under data/synthetic/, checked against
checksums/sha256-manifest.csv using scripts/Verify-Checksums.ps1.

## Preparation

The five repository copies were compared with their corresponding originals
in the local PowerShell-checks folder. All five SHA-256 comparisons matched.

A baseline manifest was then generated from the repository copies.
The saved manifest was read back and contained five entries, each recording
a size of 52 bytes and a SHA256 hash.

## Observed verification result

On 2026-11-03, the operator ran the saved verification script and reported:

    PASS: All 5 files match the saved checksum baseline.

This record transcribes the reported result; it is not an automatically
captured execution log.

## Interpretation

At the time of the reported check, the five checked repository files matched
their recorded baseline sizes and SHA-256 hashes.

The comparison with the originals established agreement at the time of
copy verification, not agreement with an independently recorded earlier state.

## Limitations

This result covers only the five manifest-listed files.
It does not validate the manifest or script against an independent trusted copy,
and it does not establish archival authenticity or completeness.

## Baseline handling

The verification script reads the files and manifest without modifying them.
The saved baseline is to be retained unchanged for subsequent checks.

## GitHub upload/download round-trip verification

### Date

2026-11-03.

### Source and transfer

The synthetic demonstration was uploaded to the GitHub repository:

NoelChibhira/archival-data-migration-toolkit

The reported upload commit was a35b537.

A ZIP snapshot of the main branch was subsequently downloaded from GitHub
and extracted into a separate Downloads folder.

The downloaded demonstration was located at:

Downloads/archival-data-migration-toolkit-main/hartley-papers-synthetic-demo

The exact commit represented by the downloaded ZIP was not independently
recorded. The upload commit above identifies the reported upload, not a
confirmed commit identity for the downloaded snapshot.

### Baseline and method

The five downloaded demonstration TXT files were checked against the
original local checksums/sha256-manifest.csv retained in the working project.

The comparison used the retained local manifest, not the manifest included
in the downloaded ZIP. File sizes and freshly calculated SHA-256 hashes
were compared with the saved baseline values.

### Reported results

| File | Size matches | SHA-256 matches | Status |
| --- | --- | --- | --- |
| data/synthetic/hartley-demo-01.txt | True | True | PASS |
| data/synthetic/hartley-demo-02.txt | True | True | PASS |
| data/synthetic/hartley-demo-03.txt | True | True | PASS |
| data/synthetic/hartley-demo-04.txt | True | True | PASS |
| data/synthetic/hartley-demo-05.txt | True | True | PASS |

The operator reported the following final message:

    PASS: All 5 downloaded files match the original local checksum baseline.

### Interpretation and limitations

All five downloaded demonstration objects matched the retained local
baseline in both file size and SHA-256 hash after upload and download.

This result covers the five TXT files only. It does not verify the downloaded
README, verification record, verification script or checksum manifest.
It does not establish archival authenticity, ownership or completeness.

This entry transcribes the operator-reported PowerShell output.
It is not an automatically captured execution log.

The original checksum baseline was retained unchanged.
