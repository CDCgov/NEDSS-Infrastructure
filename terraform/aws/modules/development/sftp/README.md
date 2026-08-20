# Terraform AWS Module: development/sftp

## Description

This module deploys and configures NBS7 development resources for an SFTP service to load/validate/split/queue hl7 messages using AWS Transfer Family, S3, Lambda, DynamoDB, and SNS.

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

## Module Details

<!-- BEGIN_TF_DOCS -->

### Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | n/a     |
| <a name="provider_local"></a> [local](#provider_local)    | n/a     |
| <a name="provider_random"></a> [random](#provider_random) | n/a     |
| <a name="provider_tls"></a> [tls](#provider_tls)          | n/a     |

### Resources

| Name                                                                                                                                                                    | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_dynamodb_table.hl7_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)                                             | resource |
| [aws_iam_role.sftp_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                          | resource |
| [aws_iam_role.transfer_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                   | resource |
| [aws_iam_role_policy.sftp_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                     | resource |
| [aws_iam_role_policy_attachment.transfer_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)        | resource |
| [aws_s3_bucket.hl7](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                              | resource |
| [aws_s3_object.inbox_folders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object)                                                    | resource |
| [aws_s3_object.site_folders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object)                                                     | resource |
| [aws_secretsmanager_secret.admin_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                            | resource |
| [aws_secretsmanager_secret.ssh_private_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                         | resource |
| [aws_secretsmanager_secret.user_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                             | resource |
| [aws_secretsmanager_secret_version.admin_secrets_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)    | resource |
| [aws_secretsmanager_secret_version.ssh_private_keys_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.user_secrets_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)     | resource |
| [aws_sns_topic.error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                            | resource |
| [aws_sns_topic.success](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                          | resource |
| [aws_sns_topic.summary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                          | resource |
| [aws_transfer_server.sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server)                                                 | resource |
| [aws_transfer_user.sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_user)                                                     | resource |
| [aws_transfer_user.site_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_user)                                               | resource |
| [local_file.sftp_credentials_csv](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)                                                   | resource |
| [random_password.admin_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                              | resource |
| [random_password.user_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                               | resource |
| [tls_private_key.user_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                                                    | resource |

### Inputs

| Name                                                                                                                  | Description                                           | Type                                                                                                          | Default                                                                                                | Required |
| --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | :------: |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name)                                                    | Name of the S3 bucket for HL7 uploads                 | `string`                                                                                                      | n/a                                                                                                    |   yes    |
| <a name="input_notification_emails"></a> [notification_emails](#input_notification_emails)                            | Map of notification types to lists of emails          | <pre>object({<br/> error = list(string)<br/> success = list(string)<br/> summary = list(string)<br/> })</pre> | n/a                                                                                                    |   yes    |
| <a name="input_enable_error_notifications"></a> [enable_error_notifications](#input_enable_error_notifications)       | Enable SNS notifications for errors                   | `bool`                                                                                                        | `true`                                                                                                 |    no    |
| <a name="input_enable_sftp"></a> [enable_sftp](#input_enable_sftp)                                                    | Enable AWS Transfer Family server + user setup        | `bool`                                                                                                        | `true`                                                                                                 |    no    |
| <a name="input_enable_split_and_validate"></a> [enable_split_and_validate](#input_enable_split_and_validate)          | Enable HL7 validation and OBR-splitting Lambda        | `bool`                                                                                                        | `true`                                                                                                 |    no    |
| <a name="input_enable_ssh_keys"></a> [enable_ssh_keys](#input_enable_ssh_keys)                                        | Enable SSH public key upload for SFTP users           | `bool`                                                                                                        | `false`                                                                                                |    no    |
| <a name="input_enable_success_notifications"></a> [enable_success_notifications](#input_enable_success_notifications) | Enable SNS notifications for success                  | `bool`                                                                                                        | `true`                                                                                                 |    no    |
| <a name="input_enable_summary_notifications"></a> [enable_summary_notifications](#input_enable_summary_notifications) | Enable daily summary notifications                    | `bool`                                                                                                        | `true`                                                                                                 |    no    |
| <a name="input_sites"></a> [sites](#input_sites)                                                                      | Map of sites and their publishers/providers           | `map(list(string))`                                                                                           | <pre>{<br/> "siteA": [<br/> "lab1",<br/> "lab2"<br/> ],<br/> "siteB": [<br/> "lab3"<br/> ]<br/>}</pre> |    no    |
| <a name="input_summary_schedule_expression"></a> [summary_schedule_expression](#input_summary_schedule_expression)    | EventBridge cron expression for summary notifications | `string`                                                                                                      | `"cron(0 0 * * ? *)"`                                                                                  |    no    |

### Outputs

| Name                                                                                                     | Description                                                      |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| <a name="output_bucket_name"></a> [bucket_name](#output_bucket_name)                                     | The name of the S3 bucket used for HL7 file uploads              |
| <a name="output_dynamodb_table_name"></a> [dynamodb_table_name](#output_dynamodb_table_name)             | The name of the DynamoDB table for logging HL7 processing errors |
| <a name="output_sftp_usernames_and_dirs"></a> [sftp_usernames_and_dirs](#output_sftp_usernames_and_dirs) | n/a                                                              |
| <a name="output_site_admins"></a> [site_admins](#output_site_admins)                                     | n/a                                                              |
| <a name="output_sns_error_topic_arn"></a> [sns_error_topic_arn](#output_sns_error_topic_arn)             | n/a                                                              |
| <a name="output_sns_success_topic_arn"></a> [sns_success_topic_arn](#output_sns_success_topic_arn)       | n/a                                                              |
| <a name="output_sns_summary_topic_arn"></a> [sns_summary_topic_arn](#output_sns_summary_topic_arn)       | n/a                                                              |

<!-- END_TF_DOCS -->
