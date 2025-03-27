# HL7 SFTP Transfer Family Pipeline

This Terraform module sets up a SFTP service to load/validate/split/queue hl7 messages using AWS Transfer Family, S3, Lambda, DynamoDB, and SNS.

---

## Features

- SFTP access via AWS Transfer Family
- Per-site and per-publisher directory structure in S3
- HL7 file validation + OBR splitting
- Dynamically named files using OBR.4.1 (Test Code) and OBR.7 (Observation Date)
- Error logging to DynamoDB
- SNS notifications:
  - Errors (invalid HL7, upload failure, etc.)
  - Success (file processed and split)
  - Daily summaries
- Email alerts with multi-recipient support
- Feature flags to enable/disable parts of the pipeline

---

##  Inputs (Terraform Flags)

- bucket_name
- enable_sftp
- enable_split_and_validate 
- enable_error_notifications
- enable_success_notifications
- enable_summary_notifications
- notification_emails
- sites
- summary_schedule_expression

---

## Outputs

TBD – could include Transfer Server ID, SNS ARNs, etc.

---

## Folder Structure

lambda/
  copy_to_inbox.py         # HL7 validation, splitting, success/error notification
  summary_report.py        # Scans DynamoDB and sends summary email
main.tf                    # Core infrastructure
variables.tf               # Input variables
outputs.tf                 # Output values
README.md                  # You are here ✅

---

## Next Steps

- [ ] Connect the `lambda/summary_report.py` Lambda to DynamoDB + SNS
- [ ] Implement publisher-level filtering (e.g., include/exclude certain publishers)
- [ ] Auto-expire DynamoDB records (TTL)

---

