# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used to create AWS VPC endpoints and required vpc endpoint resources for AWS Prometheus and AWS Grafana.

## Values

Below are the available Variables contained within this VPC module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| create_grafana_vpc_endpoint | boolean | `true` | Create Grafana VPC endpoint and security group? |
| create_prometheus_vpc_endpoint | boolean | `true` | Create Prometheus VPC endpoint and security group? |
| private_subnet_ids | list(any) |  | Private VPC subnet IDs to associate with vpc endpoints. |
| resource_prefix | string | `cdc-nbs` | Prefix for resource names |
| tags | map(string) |  | Tags to associate with created resources. |
| vpc_cidr_block | string |  | CIDR block of your VPC. |
| vpc_id | string |  | The ID of your provisioned VPC. |

## Outputs

Below are the referenceable outputs from this module.

N/A

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

N/A