# Archival Data Migration Toolkit

A professional continuing professional development (CPD) framework exploring structural metadata validation, automated data triage, and programmatic quality control checks for institutional digital archives.

## Project Overview

Before migrating complex legacy datasets into digital repositories (such as AtoM, Omeka S, or relational databases), structural metadata must be rigorously validated against organizational rules. This project implements a robust, programmatic validation engine built in Windows PowerShell to enforce structural compliance across a 1,000-record technical document register.

The toolkit moves beyond passive checking by incorporating an adversarial testing framework, proving that the engine actively intercepts and structures data failures rather than simply reporting a clean pass.

---

## Validation Engine Architecture (`Test-SandboxRegister.ps1`)

The core utility operates as a strict, non-destructive validation gateway. It parses raw ingestion manifests and evaluates row-level metadata compliance against an immutable set of structural expectations.

### 1. Enforced Mandatory Fields
The validation script flags any record exhibiting null or whitespace truncations within core descriptive columns:
* `Document ID`
* `Document Title`
* `Document Type`
* `Discipline`
* `Project / Programme`
* `Revision`
* `Document Status`
* `Security Classification`

### 2. Dynamic Pattern Matching & Prefix Handling
Document naming rules are enforced via a generalized regular expression pattern. This dynamically adapts to accept any valid 3-letter capital discipline code combined with a strict 5-digit index sequence:
```powershell
-IdPattern "^SYN-[A-Z]{3}-\d{5}\$"
```
This regex ensures strict compliance while seamlessly accommodating multi-disciplinary registries containing a mix of Project (`SYN-PRO-`), Engineering (`SYN-ENG-`), and Construction (`SYN-CON-`) structural identifiers.

---

## Testing & Quality Control Matrix

### Baseline Production Validation Run
When processed against the validated baseline dataset (`Technical Document Register–PowerShell Validation Export.csv`), the script successfully achieved a clean structural baseline:
* **Records Checked:** 1000
* **Expected Count Matches:** True
* **Records Passing Quality Checks:** 1000
* **Records Requiring Review:** 0
* **Overall Ingestion Outcome:** Passed Configured Checks

### Adversarial Fault-Injection Simulation
To prove the utility's structural sensitivity and defensive parsing capabilities, an intentional corruption matrix was programmatically injected into a secondary test dataset (`Technical Document Register–Adversarial Test.csv`). 

The utility successfully detected, captured, and structurally isolated all 4 deliberate faults:

| Injected Fault Category | Targeted Data Row | Automated Script Exception Message | Capture Status |
| :--- | :---: | :--- | :---: |
| **Blank Mandatory Value** | Row 5 | `Document Title cannot be empty or null` | **Verified Catch** |
| **Duplicate Primary Identifier** | Row 11 | `Duplicate Document ID detected: [SYN-PRO-00010]` | **Verified Catch** |
| **Malformed Pattern Violation** | Row 20 | `Document ID does not match configured pattern` | **Verified Catch** |
| **Truncated Record Count** | Last Row | `Record count matches: False (Expected 1000, evaluated 999)` | **Verified Catch** |

---

## Technical Audit Artifacts

When exceptions are triggered, the script automatically formats and builds unique, time-stamped execution directories within the working folder to prevent log overwriting:
* `validation-report.csv`: A comprehensive structural audit of row-by-row health metrics.
* `exceptions.csv`: An isolated triage manifest mapping exact line numbers, corrupted identifiers, and discrete failure explanations to streamline programmatic clean-up.

---

## Critical Ingestion & Boundary Limitations

As a rigorous metadata engineering standard, passing this script’s criteria establishes structural compliance only. This validation boundary does **not** certify or replace:
1. **Descriptive Content Validation:** Automated scripts check for text presence; they cannot verify the human accuracy or descriptive quality of a document title.
2. **Engineering Integrity:** The script validates formatting constraints; it does not review structural calculations or physical specification tolerances.
3. **Access Control Compliance:** Passing metadata checks confirms that a security classification tag exists, not that the data privacy level complies with statutory regulations or corporate access rules.
4. **Preservation Readiness:** Structural validation does not assess underlying digital asset file formats for corruption, bit-rot, or long-term preservation readiness.

## Tools & Core Concepts Explored
* **Scripting Languages:** Windows PowerShell (Set-StrictMode, advanced parameter filtering, structural pipeline processing).
* **Data Processing:** CSV structured formatting, object array indexing, automated file lock resolution.
* **Information Science:** Regular expressions (RegEx), database schema definition scripting, validation logging.
* **Archival Frameworks:** Structural triage, flat to relational data transformations, metadata migration strategies.
