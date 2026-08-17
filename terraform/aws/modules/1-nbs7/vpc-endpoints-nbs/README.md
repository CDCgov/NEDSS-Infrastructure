# Terraform <CLOUD_PROVIDER> Module: 1-nbs7/vpc-endpoints-nbs

## Description

This module is used to deploy and configure AWS VPC endpoints and related resources for AWS Prometheus and AWS Grafana in NBS7.

### References

- []()

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 6.21.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_security_group.grafana_vpc_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)    | resource    |
| [aws_security_group.prometheus_vpc_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource    |
| [aws_vpc_endpoint.grafana_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)           | resource    |
| [aws_vpc_endpoint.prometheus_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)            | resource    |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                 | data source |

## Inputs

| Name                                                                                                                        | Description                                             | Type          | Default     | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------- | ----------- | :------: |
| <a name="input_create_grafana_vpc_endpoint"></a> [create_grafana_vpc_endpoint](#input_create_grafana_vpc_endpoint)          | Create Grafana VPC endpoint and security group?         | `bool`        | `true`      |    no    |
| <a name="input_create_prometheus_vpc_endpoint"></a> [create_prometheus_vpc_endpoint](#input_create_prometheus_vpc_endpoint) | Create Prometheus VPC endpoint and security group?      | `bool`        | `true`      |    no    |
| <a name="input_private_subnet_ids"></a> [private_subnet_ids](#input_private_subnet_ids)                                     | Private VPC subnet IDs to associate with vpc endpoints. | `list(any)`   | n/a         |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                              | Prefix for resource names                               | `string`      | `"cdc-nbs"` |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                               | Tags to associate with created resources.               | `map(string)` | n/a         |   yes    |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block)                                                 | CIDR block of your VPC.                                 | `string`      | n/a         |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                         | The ID of your provisioned VPC.                         | `string`      | n/a         |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
