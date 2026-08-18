# Terraform AWS Module: development/sas9

## Description

This module is used to deploy and configure NBS7 development resources for SAS. It will deploy an EC2 from a preconfigured AMI with SAS installed

There are some required scripts and files that need to be on the AMI
for use in addition to the core SAS install

This starts the service:

- /etc/systemd/system/sas_spawner.service - systemd service script - spawns process as SAS user

The following files start as templates and have values searched and replaced as part of provisioning:

- /etc/systemd/system/sas_spawner.env - environment variables read in by service script
- /home/SAS/.odbc.ini - odbc setup for SAS user
- /etc/odbc.ini - system ODBC setup
- /home/SAS/.bashrc - SAS user environment variables - PATH etc.
- /home/SAS/update_config.sql - SQL to update the NBS6 DB to point to the new server

The values replaced in the template are derived from the parameter store,
local IP address and AWS cli logic

TODO:

- format README
- change ec2 module
- fetch license file from parameter store, secrets manager or local s3?
  don't recall size constraints
- use resource prefix in deployment file and pass that as variable for
  resource names
- possibly add the template files to this module
- since the user data script can be used on the system for refresh later
  AND custom files are already required on the AMI possibly we make all
  that is in user data live on the AMI and just call it from user data
- add more error checking to script
- parameterize more values (DB, user, etc)

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_instance_profile.sas_iam_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.sas_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_readonly_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2_ssm_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.sas9](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.sas_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_sas_ami"></a> [sas\_ami](#input\_sas\_ami) | sas9 ami from shared services account | `any` | n/a | yes |
| <a name="input_sas_instance_type"></a> [sas\_instance\_type](#input\_sas\_instance\_type) | sas9 ami from shared services account | `any` | n/a | yes |
| <a name="input_sas_keypair_name"></a> [sas\_keypair\_name](#input\_sas\_keypair\_name) | sas9 ami from shared services account | `any` | n/a | yes |
| <a name="input_sas_kms_key_id"></a> [sas\_kms\_key\_id](#input\_sas\_kms\_key\_id) | kms key arn to be used to encrypt root volume | `any` | n/a | yes |
| <a name="input_sas_subnet_id"></a> [sas\_subnet\_id](#input\_sas\_subnet\_id) | private subnet for sas server | `any` | n/a | yes |
| <a name="input_sas_vpc_id"></a> [sas\_vpc\_id](#input\_sas\_vpc\_id) | vpc id for the sas security group | `any` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | vpc cidr allowing traffic to rds and wildfly | `any` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |
| <a name="input_sas_root_volume_size"></a> [sas\_root\_volume\_size](#input\_sas\_root\_volume\_size) | root volume size for sas server | `string` | `"200"` | no |
| <a name="input_vpn_cidr_block"></a> [vpn\_cidr\_block](#input\_vpn\_cidr\_block) | vpn vpc cidr block from which to ssh into ec2 | `string` | `"10.3.0.0/16"` | no |
<!-- END_TF_DOCS -->
