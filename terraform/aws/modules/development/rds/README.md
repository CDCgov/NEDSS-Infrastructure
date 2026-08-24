# Terraform AWS Module: development/rds

## Description

This module deploys and configures NBS 7 development resources for AWS Relational Database Service (RDS)

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 5.25   |

### Modules

| Name                                                  | Source                                   | Version |
| ----------------------------------------------------- | ---------------------------------------- | ------- |
| <a name="module_db"></a> [db](#module_db)             | terraform-aws-modules/rds/aws            | 6.3.0   |
| <a name="module_rds_sg"></a> [rds_sg](#module_rds_sg) | terraform-aws-modules/security-group/aws | n/a     |

### Inputs

| Name                                                                                                               | Description                                                                    | Type                                                                     | Default                                                                                       | Required |
| ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | :------: |
| <a name="input_db_instance_type"></a> [db_instance_type](#input_db_instance_type)                                  | Database instance type                                                         | `string`                                                                 | n/a                                                                                           |   yes    |
| <a name="input_db_snapshot_identifier"></a> [db_snapshot_identifier](#input_db_snapshot_identifier)                | Database snapshot to use for RDS isntance                                      | `string`                                                                 | n/a                                                                                           |   yes    |
| <a name="input_private_subnet_ids"></a> [private_subnet_ids](#input_private_subnet_ids)                            | Subnet Ids to be used when creating RDS                                        | `list(any)`                                                              | n/a                                                                                           |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                     | Resource prefix for resources created by this module                           | `string`                                                                 | n/a                                                                                           |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                | VPC ID of virtual private cloud                                                | `string`                                                                 | n/a                                                                                           |   yes    |
| <a name="input_app_security_group_id"></a> [app_security_group_id](#input_app_security_group_id)                   | Security group id of NBS6 instance to allow traffic into RDS                   | `string`                                                                 | `null`                                                                                        |    no    |
| <a name="input_apply_immediately"></a> [apply_immediately](#input_apply_immediately)                               | Apply db changes immediately by default                                        | `bool`                                                                   | `false`                                                                                       |    no    |
| <a name="input_ingress_vpc_cidr_blocks"></a> [ingress_vpc_cidr_blocks](#input_ingress_vpc_cidr_blocks)             | CSV of CIDR blocks which will have access to RDS instance                      | `string`                                                                 | `""`                                                                                          |    no    |
| <a name="input_manage_master_user_password"></a> [manage_master_user_password](#input_manage_master_user_password) | Set to true to allow RDS to manage the master user password in Secrets Manager | `bool`                                                                   | `false`                                                                                       |    no    |
| <a name="input_parameter_group_description"></a> [parameter_group_description](#input_parameter_group_description) | Description for the parameter group                                            | `string`                                                                 | `"sql server se 15.0 custom parameter group"`                                                 |    no    |
| <a name="input_parameter_group_name"></a> [parameter_group_name](#input_parameter_group_name)                      | Name of the parameter group                                                    | `string`                                                                 | `"custom-db-parameter-group"`                                                                 |    no    |
| <a name="input_parameters"></a> [parameters](#input_parameters)                                                    | List of parameter settings for the parameter group                             | <pre>list(object({<br/> name = string<br/> value = string<br/> }))</pre> | <pre>[<br/> {<br/> "name": "ad hoc distributed queries",<br/> "value": "1"<br/> }<br/>]</pre> |    no    |

### Outputs

| Name                                                                          | Description |
| ----------------------------------------------------------------------------- | ----------- |
| <a name="output_nbs_db_address"></a> [nbs_db_address](#output_nbs_db_address) | n/a         |

<!-- END_TF_DOCS -->
