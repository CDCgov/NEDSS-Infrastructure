# Terraform Deployment of Amazon Managed Streaming for Apache Kafka (MSK)

## Description

This module is used to deploy and configure an Amazon Managed Streaming for Apache Kafka (MSK). 


## Inputs

Below are the input parameter variables for the MSK:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| environment | string | `development` | The environment, either 'development' or 'production' |
| modern-cidr | string |  | VPC CIDR to be used with cluster SG |
| msk_ebs_volume_size | number |  | EBS volume size for the MSK broker nodes in GB |
| msk_security_groups | list(string) |  | A list of security groups to use for the MSK cluster  |
| msk_subnet_ids | list(string) |  | A list of subnets to use for the MSK cluster  |
| resource_prefix | string |  | Prefix for resource names |
| vpc_id | string |  | VPC Id to be used with cluster |
| vpn-cidr | string |  | VPN VPC CIDR to be used with cluster SG |


## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.


