# Simple Archival Intake & SIP Preparation Utility

## 1. Project Purpose
This utility is an intake script designed to support **Submission Information Package (SIP) preparation** workflows. Informed by digital curation concepts, the utility provides foundational data integrity checks for file streams before they enter a formal permanent repository.

## 2. Core Capabilities & Realistic Archival Scope
* **Support for Preservation of Arrangement:** Captures relative folder paths to help retain the collection's structure during transfer.
* **Baseline Fixity Registration:** Generates dual **MD5 and SHA-256** checksum strings. This does not alter or preserve the file, but it registers a vital baseline value for later integrity verification and change detection.
* **Zero-Byte Ingest Isolation:** Identifies zero-byte empty files and transfers them into a `Quarantine_Hold` folder. To avoid file-system write errors or data loss, the quarantine engine appends a distinct GUID string to every file to completely prevent quarantine name collisions.
* **Error Isolation:** Employs independent try/catch logging checks for both the hashing engine and the file-movement system. Files that hit access errors are marked as `Review` or `Error` instead of showing an inaccurate pass.

## 3. Schema Manifest Definition
The processing workflow creates a detailed CSV manifest logging these specific baseline schema parameters:
* **DigitalAssetID:** A random tracking identifier generated at runtime.
* **OriginalFileName:** The filename captured at ingest.
* **RelativeFolderPath:** Retains folder paths to assist with arrangement.
* **FileSize_Bytes:** Physical footprint used for size tracking.
* **BaselineHash_MD5 / BaselineHash_SHA256:** Cryptographic hashes providing a baseline for later change detection (with SHA-256 tracked as the modern standard layout).
* **ProcessingTimestamp:** The precise script processing execution time (`Get-Date`).
* **IntakeStatus:** Logs evaluation metrics (`Pass`, `Fail`, `Review`, `Error`).
* **AdministrativeNotes:** Logs explicit system actions or detailed read errors.
