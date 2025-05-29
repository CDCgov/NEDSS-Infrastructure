# lambda_split_dat

## Purpose

Processes incoming HL7 `.dat` batch files uploaded to S3, splitting them into individual HL7 messages, validating and cleaning certain fields, and writing the cleaned messages to S3 as new files. This ensures HL7 messages conform to key standards (PID-10, PID-22, PID-33, etc.) for downstream systems.

## How It Works

- Triggered by S3 events for `.dat` files under `/incoming/`.
- Splits batch files by the "MSH" segment.
- Parses each message with the `python-hl7` library.
- Validates and cleans:
  - **PID-33**: Clears if not a valid HL7 date/time.
  - **PID-10 (Race)**: Only allows known race codes/systems; else clears field.
  - **PID-22 (Ethnic Group)**: Similar validation as race.
- Writes each cleaned message as a new HL7 file under a `splitdat` output prefix.

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
- Libraries: `boto3`, `hl7` (`python-hl7`), `logging`, `re`, `datetime`, `os`, `json`, `traceback`, `uuid`.

## Deployment

S3 event for `*.dat` files in `/incoming/` directories.

---
