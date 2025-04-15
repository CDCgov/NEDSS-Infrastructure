# HL7 SFTP Transfer Family Pipeline

This Terraform module sets up a SFTP service to load/validate/split/queue hl7 messages using AWS Transfer Family, S3, Lambda, DynamoDB, and SNS.

---
## TODO:

- fix homedir to include server name, when users added manually we pick the bucket and the site name populates
- fix service managed accounts to use passwords from secrets manager, they should allow them automagically when naming convention is correct
- name resources with a prefix or some way identify, not intended to be PART of core install but we MIGHT find cases of adding to full deployment
- test lambdas and workflow using lambdas, create zip 
- data calls see comments in https://github.com/CDCgov/NEDSS-Infrastructure/pull/198

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

## Getting Started

1. Review and update `variables.tf` to match your environment
2. Customize your `sites` and email lists
3. Deploy using:

```bash
define notification emails, s3 bucket, sites and providers in terraform.tfvars
terraform init
terraform apply
```

4. Confirm SNS subscriptions via email
5. Upload test HL7 files to your site/publisher S3 folders via SFTP

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

```bash
lambda/
  copy_to_inbox.py         # HL7 validation, splitting, success/error notification
  summary_report.py        # Scans DynamoDB and sends summary email
main.tf                    # Core Terraform resources (S3, Lambda, Transfer Family, etc.)
variables.tf               # Input variables and feature flags
outputs.tf                 # Output values
README.md                  # Documentation (you are here ✅)
```

---

## Next Steps

- [ ] Connect the `lambda/summary_report.py` Lambda to DynamoDB + SNS
- [ ] Implement publisher-level filtering (e.g., include/exclude certain publishers)
- [ ] Auto-expire DynamoDB records (TTL)
- [ ] Connect downstream systems to consume inbox files
- [ ] Add virus scanning or schema validation

---

