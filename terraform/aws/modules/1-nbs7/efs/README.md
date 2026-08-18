# Terraform AWS Module: 1-nbs7/efs

## Description

This module is used to deploy and configure AWS Elastic File System (EFS) and related resources for NBS7.

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
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | >=2.0.0, <3.0.0 |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | AWS KMS key resource name to be used for EFS encryption | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for EFS | `string` | n/a | yes |
| <a name="input_mount_targets"></a> [mount\_targets](#input\_mount\_targets) | Mount targets to be used for EFS | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used for EFS (an overwrite option to use a custom name) | `string` | `""` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |
| <a name="input_vpc_cidrs"></a> [vpc\_cidrs](#input\_vpc\_cidrs) | list of VPC CIDRs | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
<!-- END_TF_DOCS -->
