# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for AWS VPC purposes.

## Values

Below are the available Variables contained within this VPC module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| azs | list |  | List of AWS availability zones in current region |
| cidr | string |  | CIDR block of your VPC |
| create_igw | boolean |  | Create an internet gateway(requires public subnet)? |
| enable_nat_gateway | boolean |  | Create NAT gateway |
| enable_dns_hostnames | boolean | `false` | Should be true to enable DNS hostnames in the VPC |
| enable_dns_support | boolean | `true` | Should be true to enable DNS support in the VPC |
| name | string |  | Name of your VPC |
| one_nat_gateway_per_az | boolean |  | Use a single NAT gateway for each availability zone |
| private_subnets | list |  | List of CIDR blocks for each private subnets to be created |
| public_subnets | list |  | List of CIDR blocks for each public subnets to be created |
| single_nat_gateway | boolean|  | Use a single NAT gateway (low availability) |

Below are the available Outputs contained within this DNS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| vpc_id |  | `module.vpc.vpc_id` | VPC ID |
| private_route_table_id |  | `module.vpc.private_route_table_ids[0]` | Private VPC Route Table ID's |
| private_subnets |  | `module.vpc.private_subnets` | Private VPC Subnets |
| private_subnets_cidr_blocks |  | `module.vpc.private_subnets_cidr_blocks` | Private VPC Subnet CIDR Blocks |
| public_route_table_id |  | `module.vpc.public_route_table_ids[0]` | Public VPC Route Table ID's |
| public_subnets |  | `module.vpc.public_subnets` | Public VPC Subnets |
| public_subnets_cidr_blocks |  | `module.vpc.public_subnets_cidr_blocks` | Public VPC Subnet CIDR Blocks |
