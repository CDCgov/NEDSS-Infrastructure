# Terraform AWS Module: development/ebs

## Description

This module is used to deploy and configure NBS7 development resources for AWS Elastic Block Store (EBS)

## Module Details

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_ebs_encryption_by_default.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_ebs_encryption_by_default"></a> [enable\_ebs\_encryption\_by\_default](#input\_enable\_ebs\_encryption\_by\_default) | Enable EBS Encryption by Default | `bool` | `true` | no |
<!-- END_TF_DOCS -->
