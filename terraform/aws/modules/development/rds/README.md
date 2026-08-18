# Terraform AWS Module: development/rds

## Description

This module is used to deploy and configure NBS7 development resources for AWS Relational Database Service (RDS)

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.25 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_db"></a> [db](#module\_db) | terraform-aws-modules/rds/aws | 6.3.0 |
| <a name="module_rds_sg"></a> [rds\_sg](#module\_rds\_sg) | terraform-aws-modules/security-group/aws | n/a |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | Database instance type | `string` | n/a | yes |
| <a name="input_db_snapshot_identifier"></a> [db\_snapshot\_identifier](#input\_db\_snapshot\_identifier) | Database snapshot to use for RDS isntance | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Subnet Ids to be used when creating RDS | `list(any)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Resource prefix for resources created by this module | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID of virtual private cloud | `string` | n/a | yes |
| <a name="input_app_security_group_id"></a> [app\_security\_group\_id](#input\_app\_security\_group\_id) | Security group id of NBS6 instance to allow traffic into RDS | `string` | `null` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply db changes immediately by default | `bool` | `false` | no |
| <a name="input_ingress_vpc_cidr_blocks"></a> [ingress\_vpc\_cidr\_blocks](#input\_ingress\_vpc\_cidr\_blocks) | CSV of CIDR blocks which will have access to RDS instance | `string` | `""` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the master user password in Secrets Manager | `bool` | `false` | no |
| <a name="input_parameter_group_description"></a> [parameter\_group\_description](#input\_parameter\_group\_description) | Description for the parameter group | `string` | `"sql server se 15.0 custom parameter group"` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the parameter group | `string` | `"custom-db-parameter-group"` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of parameter settings for the parameter group | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "ad hoc distributed queries",<br/>    "value": "1"<br/>  }<br/>]</pre> | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nbs_db_address"></a> [nbs\_db\_address](#output\_nbs\_db\_address) | n/a |
<!-- END_TF_DOCS -->
