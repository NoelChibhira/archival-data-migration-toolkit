# Technical Documentation: Digital Archival Ingest & Automated Triage Utility

## 1. Executive Summary
This utility functions as an automated Pre-Ingest Triage and Data Integrity System for digital heritage repositories. Built natively in PowerShell, the tool programmatically scans incoming unstructured file streams, evaluates their physical integrity, computes cryptographic fixity hashes, and segregates corrupt or unviable digital assets into a restricted administrative quarantine branch. 

By automating these checks, the utility enforces bit-level preservation and collection appraisal rules before records are ingested into permanent collection management networks (e.g., AtoM, Axiell Calm, DSpace).

---

## 2. Core Archival Architecture & Workflow
The system maps directly to the Submission Information Package (SIP) ingestion phase of the international OAIS (Open Archival Information System) Reference Model.

## 3. Detailed Processing Phase Breakdown

### Phase 1: Object Discovery and Path Mapping
The script initializes by securely mapping the absolute directory paths of the target repository. It uses recursive directory parsing to traverse the entire folder hierarchy. To ensure processing stability, it actively ignores its own administrative quarantine folders (Quarantine_Hold) during execution.

### Phase 2: System Metadata Extraction
For every individual digital object discovered, the utility queries the underlying file system to capture critical descriptive and administrative metadata properties:
*   Original File Name & Format Extension: Preserves the provenance of the file naming convention and logs the precise technical format type (e.g., .PDF, .PNG, .TXT, .XLSX).
*   Absolute Relative Pathing: Tracks the internal structural layout of the file structure to maintain original order (respect des fonds).
*   Exact Byte Volume: Measures the digital object down to individual byte metrics.

### Phase 3: Cryptographic Fixity Verification
To protect files against long-term bit-rot or undetected alteration, the utility opens the file stream and processes its binary content using the MD5 (Message Digest 5) algorithm. This creates a permanent, unique 32-character hexadecimal alphanumeric string. This string acts as the file's digital fingerprint. If a single bit of data shifts over time, a future fixity check will produce a scrambled string, alerting archivists to data decay.

### Phase 4: Automated Appraisal and Quarantine Isolation
The tool applies an objective validation constraint to determine whether an asset is viable for permanent retention:
*   The Constraint Rule: If File Size Equals 0 Bytes = Status: Fail
*   The Log Result: Empty file shells are programmatically stamped as a Fail, and their metadata notes are updated with a critical alert: CRITICAL: Zero-byte file isolated and moved to Quarantine.
*   The Physical Quarantine Action: Instead of leaving broken links in the active collection, the utility executes a secure file system transfer (Move-Item), physically cutting the failed file out of the ingest folder and pasting it into a restricted, dedicated sub-directory named Quarantine_Hold.

---

## 4. Manifest Schema Definition (The Output Receipt)
Upon successful completion, the script exports a platform-agnostic, UTF-8 encoded CSV master manifest file (CompleteIngestManifest.csv). This spreadsheet contains the following schema elements:

*   DigitalAssetID: A globally unique, permanent tracker for identifying the asset across systems.
*   OriginalFileName: The original name of the file, preserving its structural identity.
*   RelativePath: Maps the original folder organization and hierarchy.
*   FileExtension: Tracks the format signature for technical preservation planning.
*   FileSize_Bytes: The exact physical size of the asset on disk. Used to detect corruption.
*   IngestChecksum_MD5: The cryptographic hash used for long-term fixity tracking.
*   DateDigitised: Chronological logging recording the precise second of file ingest processing.
*   FixityStatus: The data integrity status flag (Pass = healthy; Fail = data vacuum/corrupt).
*   IngestNotes: Administrative auditing notes tracking preservation actions taken on the asset.

---

## 5. Security & Technical Implementation Safeguards
*   Cryptographic Default Integrity: An empty 0-byte file will natively yield a constant hash value of D41D8CD98F00B204E9800998ECF8427E. The script uses this mathematical uniformity to verify the absolute accuracy of its data analysis.
*   File-Lock Protection (Error Handling): If an asset is actively being edited, synced, or locked by another local process, the script gracefully moves past the file exception layer, records a descriptive error status, and completes the remaining manifest processing queue without crashing the repository pipeline.
