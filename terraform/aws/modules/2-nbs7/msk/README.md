# Terraform Deployment of Amazon Managed Streaming for Apache Kafka (MSK)

## Description

This module is used to deploy and configure an Amazon Managed Streaming for Apache Kafka (MSK). 

## Inputs

Below are the input parameter variables for the MSK:

| Key            | Type           | Default        | Description    |
| -------------- | -------------- | -------------- | -------------- |
| create_msk | bool | true | Create MSK cluser and required resources? |
| environment | string | `development` | The environment - either 'development' or 'production', which means by default two brokers of size kafka.t3.small or three kafka.m5.large brokers, respectively. |
| additional_brokers_to_create | number | `0` | How many additional brokers to create - beyond the default of two for 'development' or otherwise three. AWS MSK requires that the number of brokers must be a multiple of the number of Availability Zones. |
| msk_ebs_volume_size | number |  | EBS volume size for the MSK broker nodes in GB |
| msk_security_groups | list(string) |  | A list of security groups to use for the MSK cluster  |
| msk_subnet_ids | list(string) |  | The list of subnets to use, which determines how many AZs (Availability Zones) the cluster uses. There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets. |
| resource_prefix | string | `cdc-nbs` | Prefix for resource names |
| vpc_id | string |  | VPC Id to be used with cluster |
| cidr_blocks | list(any) |  |  |
| kafka_version | string | `3.6.0` | Version of Kafka to be deployed in cluster |

## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.
