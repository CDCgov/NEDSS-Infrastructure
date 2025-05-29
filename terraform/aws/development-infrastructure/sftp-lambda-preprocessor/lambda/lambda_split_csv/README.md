# lambda_split_csv

## Purpose

This Lambda function processes incoming CSV files uploaded to S3, generates HL7 ORU^R01 messages from each row, and writes each HL7 message as a new file into a structured S3 output prefix. It is part of a pipeline converting lab data in CSV format into HL7 format for electronic lab reporting (ELR).

## How It Works

- Triggered by S3 events on new `.csv` files under a path ending in `/incoming/`.
- Reads each row of the CSV and builds a corresponding HL7 message using key patient and lab fields.
- Writes each HL7 message to a new file in a `splitcsv` output directory under the appropriate S3 path.
- Errors (such as missing fields or bad data) are logged and optionally sent to SNS.

## Directory Structure

**Input:**
```
<bucket>/<site>/<username>/incoming/<sourcefile>.csv
```
**Output:**
```
<bucket>/<site>/<username>/splitcsv/<username>_<sourcefile>_<hash>_<row_id>.hl7
```

## Environment Variables

- `ERROR_TOPIC_ARN` (optional): SNS topic ARN for error or success notifications.

## Key Features

- Skips files already processed (in `splitcsv`, `splitdat`, or `splitobr`).
- Handles and reports CSV data errors, logs all steps.
- Sends error notifications to SNS if configured.

## Required Permissions

- `s3:GetObject`, `s3:PutObject` for relevant S3 prefixes.
- `sns:Publish` (if `ERROR_TOPIC_ARN` is set).

## Dependencies

- Python 3.9+ runtime.
- Libraries: `boto3`, `csv`, `hashlib`, `logging`, `datetime`, `io`, `os`, `json`, `traceback`.

## Deployment

Configure this Lambda with an S3 event trigger for `*.csv` files in `/incoming/`.

---
