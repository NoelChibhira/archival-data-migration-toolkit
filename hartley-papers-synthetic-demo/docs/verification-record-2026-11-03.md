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