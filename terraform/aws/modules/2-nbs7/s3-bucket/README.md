# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used to create AWS S3 buckets and configuration.

## Values

Below are the available Variables contained within this VPC module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| bucket_prefix | boolean | `true` | Bucket name prefix (result is guaranteed to be unique). |
| enable_default_bucket_lifecycle_policy | string | `Enabled` | Whether the default rule is currently being applied. Valid values: Enabled or Disabled. |
| mark_object_for_delete_days | number | `30` | Number of days until a new objects is marked noncurrent (gets a delete marker). |
| delete_noncurrent_objects | number | `60` | Number of days until a noncurrent object is PERMANENTLY deleted (total days before object deletion is calculated by mark_object_for_delete_days + delete_noncurrent_objects). |
| tags | map(string) |  | Tags to associate with created resources. |
| force_destroy_bucket | boolean | false | Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. |


## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |
| bucket_prefix | Bucket name prefix (result is guaranteed to be unique).  |

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

N/A