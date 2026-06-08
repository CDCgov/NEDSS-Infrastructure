# lambda_add_hl7_ext

## Purpose

Processes incoming HL7 files without an extension uploaded to S3. Normalizes line endings, validates and cleans key fields (PID-10, PID-22, PID-33, ORC-23.9), and rewrites the content to S3 as a single cleaned `.hl7` file under a `renamed_file/` prefix. This ensures HL7 messages conform to expected standards and prevents downstream ingestion errors in NBS and related systems.

## How It Works

- Triggered by S3 events for files under `/incoming/` that lack an HL7 extension.
- Normalizes line endings and processes both single-message and batch HL7 files.
- Validates and cleans:
  - **PID-33**: Clears if not a valid HL7 date/time.
  - **PID-10 (Race)**: Only allows known race codes/systems; else clears field.
  - **PID-22 (Ethnic Group)**: Similar validation as race.
  - **ORC-23.9 (Notes):** Removed from ORC to prevent truncation errors in NBS; appended instead as a new `NTE|1|L|{collected_notes}` segment.
- Writes the cleaned HL7 messages as a single output file under the `renamed_file/` prefix with `.hl7` extension.

## Directory Structure

**Input:**
```
<bucket>/<site>/<username>/incoming/<sourcefile>.dat
```
**Output:**
```
<bucket>/<site>/<username>/splitdat/<username>_<sourcefile>_<uuid>.hl7
```

## Environment Variables

- `ERROR_TOPIC_ARN` (optional): SNS topic ARN for error reporting.

## Key Features

- HL7 compliance via field cleaning and validation.
- CloudWatch metrics for malformed/invalid codes.
- Continues processing other messages if one fails.

## Required Permissions

- `s3:GetObject`, `s3:PutObject` for bucket.
- `sns:Publish`, `cloudwatch:PutMetricData` if enabled.

## Dependencies

- Python 3.9+ runtime.
- Libraries: `boto3`, `botocore.exceptions`, `logging`, `re`, `datetime`, `os`, `json`, `traceback`, `urllib.parse`, `hl7` (optional, `python-hl7` if `USE_HL7_LIB=True`)


## Deployment

S3 event for files missing extension in `/incoming/` directories.

---
