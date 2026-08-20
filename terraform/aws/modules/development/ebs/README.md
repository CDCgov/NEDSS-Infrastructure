# Terraform AWS Module: development/ebs

## Description

This module deploys and configures NBS7 development resources for AWS Elastic Block Store (EBS)

## Module Details

<!-- BEGIN_TF_DOCS -->

### Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

### Resources

| Name                                                                                                                                           | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ebs_encryption_by_default.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |

### Inputs

| Name                                                                                                                              | Description                      | Type   | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- | ------ | ------- | :------: |
| <a name="input_enable_ebs_encryption_by_default"></a> [enable_ebs_encryption_by_default](#input_enable_ebs_encryption_by_default) | Enable EBS Encryption by Default | `bool` | `true`  |    no    |

<!-- END_TF_DOCS -->
