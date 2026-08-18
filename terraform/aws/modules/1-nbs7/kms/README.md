# Terraform AWS Module: 1-nbs7/kms

## Description

This module is used to deploy and configure AWS Key Management Service (KMS) and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | >=4.1.1, <5.0.0 |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | The list of aliases to give the key | `list(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Give your key a description. | `string` | n/a | yes |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Number of days to wait before deleting a KMS key range: 7-30 | `number` | `7` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Set to true to enable automatic key rotation | `bool` | `true` | no |
| <a name="input_key_administrators"></a> [key\_administrators](#input\_key\_administrators) | A list of IAM ARNs for key administrators | `list(any)` | `[]` | no |
| <a name="input_key_service_users"></a> [key\_service\_users](#input\_key\_service\_users) | A list of IAM ARNs for key service users | `list(any)` | `[]` | no |
| <a name="input_key_statements"></a> [key\_statements](#input\_key\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `list(any)` | `[]` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | The intended use of the key | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_key_users"></a> [key\_users](#input\_key\_users) | A list of IAM ARNs for key users | `list(any)` | `[]` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) | `bool` | `false` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
<!-- END_TF_DOCS -->
