# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline RDS resources within a respective AWS environment using Terraform. The below module is used for NBS6 database purposes.

## Values

Below are the available Variables contained within this NBS Legacy module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| apply_immediately | bool | false | Apply db changes immediately by default |
| db_instance_type | string |  | Database instance type |
| db_snapshot_identifier | string |  | Database snapshot to use for RDS instance |
| resource_prefix | string |  | Resource prefix for resources created by this module |
| manage_master_user_password | bool | false | Set to true to allow RDS to manage the master user password in Secrets Manager |
| private_subnet_ids | list |  | Subnet ID to be used when creating RDS instance |
| shared_vpc_cidr_block | string |"" | VPC CIDR block in shared services account |
| vpc_id | string |  | VPC ID in which RDS will be deployed |


Below are the available Outputs contained within this RDS module:

None
