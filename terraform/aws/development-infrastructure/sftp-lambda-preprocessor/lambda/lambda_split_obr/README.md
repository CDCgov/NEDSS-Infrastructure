# lambda_split_obr

## Purpose

Splits HL7 files containing multiple OBR segments into individual HL7 messages, each with a single OBR. This is essential when downstream systems require exactly one order per HL7 message.

## How It Works

- Triggered by S3 events for `.hl7` files in `/incoming/`.
- Parses the HL7 file by segment, grouping by `MSH`, `PID`, `ORC`, then splitting out each OBR and its related segments (OBX, NTE, etc.).
- Writes each OBR-containing message as a new file in the `splitobr` output directory.

## Directory Structure

**Input:**
```
<bucket>/<site>/<username>/incoming/<sourcefile>.hl7
```
**Output:**
```
<bucket>/<site>/<username>/splitobr/<username>_<sourcefile>_<uuid>.hl7
```

## Environment Variables

- `ERROR_TOPIC_ARN` (optional): SNS topic ARN for error notification.

## Key Features

- Ensures one OBR per output message.
- Skips already-processed files.
- Logs actions to CloudWatch; sends errors to SNS if configured.

## Required Permissions

- `s3:GetObject`, `s3:PutObject` for bucket.
- `sns:Publish` if enabled.

## Dependencies

- Python 3.9+ runtime.
- Libraries: `boto3`, `logging`, `os`, `uuid`, `json`, `traceback`.

## Deployment

S3 event for `*.hl7` files in `/incoming/` directories.

---
