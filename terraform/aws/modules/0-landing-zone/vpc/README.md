# Terraform AWS Module: 0-landing-zone/vpc

## Description

This module deploys and configures AWS Virtual Private Cloud (VPC) and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |

### Modules

| Name                                         | Source                        | Version         |
| -------------------------------------------- | ----------------------------- | --------------- |
| <a name="module_vpc"></a> [vpc](#module_vpc) | terraform-aws-modules/vpc/aws | >=6.5.1, <7.0.0 |

### Inputs

| Name                                                                                                                     | Description                                                                                                                 | Type        | Default     | Required |
| ------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- | ----------- | ----------- | :------: |
| <a name="input_azs"></a> [azs](#input_azs)                                                                               | List of AWS availability zones in current region                                                                            | `list(any)` | n/a         |   yes    |
| <a name="input_cidr"></a> [cidr](#input_cidr)                                                                            | CIDR block of your VPC                                                                                                      | `any`       | n/a         |   yes    |
| <a name="input_create_igw"></a> [create_igw](#input_create_igw)                                                          | Create an internet gateway(requires public subnet)?                                                                         | `bool`      | n/a         |   yes    |
| <a name="input_enable_nat_gateway"></a> [enable_nat_gateway](#input_enable_nat_gateway)                                  | Create NAT Gateway?                                                                                                         | `bool`      | n/a         |   yes    |
| <a name="input_one_nat_gateway_per_az"></a> [one_nat_gateway_per_az](#input_one_nat_gateway_per_az)                      | Use a single NAT Gateway for each availability zone?                                                                        | `bool`      | n/a         |   yes    |
| <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)                                           | List of CIDR blocks for each private subnets to be created                                                                  | `list(any)` | n/a         |   yes    |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)                                              | List of CIDR blocks for each private subnets to be created                                                                  | `list(any)` | n/a         |   yes    |
| <a name="input_single_nat_gateway"></a> [single_nat_gateway](#input_single_nat_gateway)                                  | Use a single NAT Gateway (low availability)?                                                                                | `bool`      | n/a         |   yes    |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames)                            | Should be true to enable DNS hostnames in the VPC                                                                           | `bool`      | `false`     |    no    |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support)                                  | Should be true to enable DNS support in the VPC                                                                             | `bool`      | `true`      |    no    |
| <a name="input_manage_default_network_acl"></a> [manage_default_network_acl](#input_manage_default_network_acl)          | Should be true to adopt and manage default network acl in the VPC                                                           | `bool`      | `false`     |    no    |
| <a name="input_manage_default_route_table"></a> [manage_default_route_table](#input_manage_default_route_table)          | Should be true to adopt and manage default route table in the VPC                                                           | `bool`      | `false`     |    no    |
| <a name="input_manage_default_security_group"></a> [manage_default_security_group](#input_manage_default_security_group) | Should be true to adopt and manage default security group in the VPC                                                        | `bool`      | `false`     |    no    |
| <a name="input_map_public_ip_on_launch"></a> [map_public_ip_on_launch](#input_map_public_ip_on_launch)                   | Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false` | `bool`      | `false`     |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                            | Name of your VPC (an overwrite option to use a custom name)                                                                 | `string`    | `""`        |    no    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                           | Prefix for resource names                                                                                                   | `string`    | `"cdc-nbs"` |    no    |

### Outputs

| Name                                                                                                                 | Description |
| -------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_private_route_table_id"></a> [private_route_table_id](#output_private_route_table_id)                | n/a         |
| <a name="output_private_subnets"></a> [private_subnets](#output_private_subnets)                                     | n/a         |
| <a name="output_private_subnets_cidr_blocks"></a> [private_subnets_cidr_blocks](#output_private_subnets_cidr_blocks) | n/a         |
| <a name="output_public_route_table_id"></a> [public_route_table_id](#output_public_route_table_id)                   | n/a         |
| <a name="output_public_subnets"></a> [public_subnets](#output_public_subnets)                                        | n/a         |
| <a name="output_public_subnets_cidr_blocks"></a> [public_subnets_cidr_blocks](#output_public_subnets_cidr_blocks)    | n/a         |
| <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output_vpc_cidr_block)                                        | n/a         |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                                                                | n/a         |

<!-- END_TF_DOCS -->
