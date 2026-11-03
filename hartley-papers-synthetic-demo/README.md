# Hartley Papers: Synthetic Integrity Demonstration

## Purpose

This repository contains a small synthetic demonstration of file-copy
verification, checksum baseline creation and repeatable integrity checking.

The five TXT files are demonstration objects, not authentic archival records.
This repository does not represent a complete digital preservation system.

## Repository structure

- data/synthetic/ - Five demonstration TXT files.
- checksums/sha256-manifest.csv - Saved SHA-256 baseline.
- scripts/Verify-Checksums.ps1 - Reusable verification script.
- docs/ - Documentation and verification records.
- schemas/ - Reserved for future schema documentation.

## Baseline scope

The checksum manifest covers these five files only:

- data/synthetic/hartley-demo-01.txt
- data/synthetic/hartley-demo-02.txt
- data/synthetic/hartley-demo-03.txt
- data/synthetic/hartley-demo-04.txt
- data/synthetic/hartley-demo-05.txt

Each file was 52 bytes when the baseline was created.

The manifest records repository-relative paths, file sizes, the SHA256
algorithm label and the corresponding hash values.

## Running verification

From the repository root, run in PowerShell:

    & ".\scripts\Verify-Checksums.ps1"

A successful check displays PASS for each of the five listed files, followed by:

    PASS: All 5 files match the saved checksum baseline.

The script reads the files and manifest without modifying them.
It checks the expected manifest file list, sizes and SHA-256 hashes.
It reports missing files or mismatches and stops with an error on failure.

## Limitations

The check covers only the five listed demonstration files.
It does not check additional, unlisted files or the integrity of the README,
verification script, manifest itself or other repository documentation.

A successful result means the checked files match the saved baseline.
It does not establish archival authenticity, ownership, completeness,
rights clearance or long-term preservation.

## Baseline management

Keep the saved manifest unchanged during routine verification.
If a file fails a check, investigate before changing the baseline.
Do not regenerate the manifest merely to make a failed check pass.

Any intentional replacement baseline should be documented and versioned
separately from the original.

## Verification history

See docs/verification-record-2026-11-03.md for the initial recorded result.