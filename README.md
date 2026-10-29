# Archival Data Migration Toolkit

A professional Continuing Professional Development (CPD) framework exploring programmatic metadata triage, automated structural validation, adversarial fault isolation, and relational data modeling for enterprise-scale institutional repositories.

Created by Noel Chibhira.

## 1. Project Purpose & Toolkit Overview

In large-scale data migrations—such as transitioning legacy records into modern digital repositories (e.g., AtoM, Omeka S, or relational corporate databases)—ingesting raw files without preprocessing introduces systemic data pollution. Missing mandatory values, duplicate keys, and malformed strings break database constraints and compromise long-term discoverability.

This toolkit functions as an automated, non-destructive data triage and validation pipeline. It provides a modular suite of tools designed to check, clean, and map metadata records before repository import.

### Core Repository Artifacts
*   **`Test-SandboxRegister.ps1`**: The primary validation engine executing automated schema checking and strict pattern matching.
*   **`ArchivalIngest.ps1`**: The core data ingestion script handling the structural transport, file streaming, and initial processing of repository manifests.
*   **`Archival_Triage_Documentation.md`**: A comprehensive procedural handbook outlining the manual and automated data-cleaning rules, structural observations, and data transformation parameters.
*   **`Technical Document Register–PowerShell Validation Export.csv`**: The verified production data baseline containing 1,000 processed rows.
*   **`Archival_Migration_Toolkit_Portfolio.zip`**: The complete, compressed distribution package containing all tools and baseline components.

---

## 2. Integrated Toolkit Workflow

The portfolio structures a multi-stage migration pipeline moving from raw data inspection to relational structure:
