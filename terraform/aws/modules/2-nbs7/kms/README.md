# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for AWS KMS purposes.

## Values

Below are the available Variables contained within this KMS module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| deletion_window_in_days | number | `7` | Number of days to wait before deleting a KMS key range: 7-30 |
| description | string |  | Give your key a description |
| enable_key_rotation | bool | `true` | Check for key rotation |
| key_administrators | list | `[]` | A list of IAM ARNs for key administrators |
| key_service_users | list | `[]` | A list IAM ARNs for key service users |
| key_usage | string | `ENCRYPT_DECRYPT` | Key Validation |
| key_users | `[]` | list | A list of IAM ARNs for key users |
| multi_region | boolean | `false` | Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) |
| key_statements | any | `{}` | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage |

Below are the available Outputs contained within this KMS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| kms_key_arn |  | `module.kms.key_arn` | Amazon Resource Name (ARN) of the KMS key |
