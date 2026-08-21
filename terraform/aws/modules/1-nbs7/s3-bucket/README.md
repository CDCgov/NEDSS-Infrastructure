# Terraform AWS Module: 1-nbs7/s3-bucket

## Description

This module deploys and configures AWS S3 buckets and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |

### Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 6.21.0  |

### Resources

| Name                                                                                                                                                                  | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                           | resource |
| [aws_s3_bucket_lifecycle_configuration.lifecyle_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)    | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                               | resource |

### Inputs

| Name                                                                                                                                                | Description                                                                                                                                                                   | Type          | Default      | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------------ | :------: |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                       | Tags to associate with created resources.                                                                                                                                     | `map(string)` | n/a          |   yes    |
| <a name="input_bucket_prefix"></a> [bucket_prefix](#input_bucket_prefix)                                                                            | Bucket name prefix (result is guaranteed to be unique).                                                                                                                       | `string`      | `"cdc-nbs"`  |    no    |
| <a name="input_delete_noncurrent_objects"></a> [delete_noncurrent_objects](#input_delete_noncurrent_objects)                                        | Number of days until a noncurrent object is PERMANENTLY deleted (total days before object deletion is calculated by mark_object_for_delete_days + delete_noncurrent_objects). | `number`      | `60`         |    no    |
| <a name="input_enable_default_bucket_lifecycle_policy"></a> [enable_default_bucket_lifecycle_policy](#input_enable_default_bucket_lifecycle_policy) | Whether the default rule is currently being applied. Valid values: Enabled or Disabled.                                                                                       | `string`      | `"Disabled"` |    no    |
| <a name="input_force_destroy_bucket"></a> [force_destroy_bucket](#input_force_destroy_bucket)                                                       | Deletes all objects, including locked objects, from the bucket when the bucket is destroyed. Set to 'true' to allow destruction without error.                                | `bool`        | `false`      |    no    |
| <a name="input_mark_object_for_delete_days"></a> [mark_object_for_delete_days](#input_mark_object_for_delete_days)                                  | Number of days until a new objects is marked noncurrent (gets a delete marker).                                                                                               | `number`      | `30`         |    no    |

### Outputs

| Name                                                                 | Description    |
| -------------------------------------------------------------------- | -------------- |
| <a name="output_bucket_name"></a> [bucket_name](#output_bucket_name) | S3 bucket name |

<!-- END_TF_DOCS -->
