# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for AWS EFS purposes.

## Values

Below are the available Variables contained within this EFS module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
<<<<<<< HEAD
| mount_targets | any | {} | Mount targets to be used for EFS |
| name | string |  | Name to be used for EFS |
| name | string |  | Name to be used for EFS |
=======
| kms_key_arn | string |  | AWS KMS key resource name to be used for EFS encryption |
| mount_targets | any | {} | Mount targets to be used for EFS |
| name | string |  | Name to be used for EFS |
>>>>>>> main
| vpc_ciders | list(string) | `["0.0.0.0/0"]` | List of VPC CIDRs |
| vpc_id | string |  | VPC ID for EFS |
