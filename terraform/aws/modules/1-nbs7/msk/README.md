# Terraform AWS Module: 1-nbs7/msk

## Description

This module is used to deploy and configure AWS Managed Streaming for Apache Kafka (MSK) and related resources for NBS7.

### References

- [AWS Docs](https://aws.amazon.com)

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

| Name                                                                                                                                                 | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_log_group.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                    | resource |
| [aws_msk_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster)                                      | resource |
| [aws_msk_configuration.msk_configuration_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) | resource |
| [aws_security_group.msk_cluster_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                      | resource |
| [aws_security_group_rule.cluster_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)          | resource |
| [aws_security_group_rule.msk_cluster_plaintext](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)     | resource |
| [aws_security_group_rule.msk_cluster_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)           | resource |

## Inputs

| Name                                                                                                                  | Description                                                                                                                                                                                                 | Type           | Default         | Required |
| --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------------- | :------: |
| <a name="input_additional_brokers_to_create"></a> [additional_brokers_to_create](#input_additional_brokers_to_create) | How many additional brokers to create - beyond the default of two for 'development' or otherwise three. AWS MSK requires that the number of brokers must be a multiple of the number of Availability Zones. | `number`       | `0`             |    no    |
| <a name="input_cidr_blocks"></a> [cidr_blocks](#input_cidr_blocks)                                                    | CIDR blocks for allowing access to MSK via security group rules                                                                                                                                             | `list(any)`    | n/a             |   yes    |
| <a name="input_create_msk"></a> [create_msk](#input_create_msk)                                                       | Create MSK cluser and required resources?                                                                                                                                                                   | `bool`         | `true`          |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                    | The environment, either 'development' or 'production'; which means by default two brokers of size kafka.t3.small or three kafka.m5.large brokers, and RF=2 or RF=3, respectively.                           | `string`       | `"development"` |    no    |
| <a name="input_kafka_version"></a> [kafka_version](#input_kafka_version)                                              | Version of Kafka to be deployed in cluster                                                                                                                                                                  | `string`       | `"3.9.x"`       |    no    |
| <a name="input_msk_ebs_volume_size"></a> [msk_ebs_volume_size](#input_msk_ebs_volume_size)                            | EBS volume size for the MSK broker nodes in GB                                                                                                                                                              | `number`       | n/a             |   yes    |
| <a name="input_msk_subnet_ids"></a> [msk_subnet_ids](#input_msk_subnet_ids)                                           | The list of subnets to use, which determines how many AZs (Availability Zones) the cluster uses. There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets.                            | `list(string)` | n/a             |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                        | Prefix for resource names                                                                                                                                                                                   | `string`       | `"cdc-nbs"`     |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                   | VPC Id to be used with cluster                                                                                                                                                                              | `string`       | n/a             |   yes    |

## Outputs

| Name                                                                                                        | Description                                      |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| <a name="output_bootstrap_brokers"></a> [bootstrap_brokers](#output_bootstrap_brokers)                      | The bootstrap brokers for the MSK cluster        |
| <a name="output_zookeeper_connect_string"></a> [zookeeper_connect_string](#output_zookeeper_connect_string) | The Zookeeper connect string for the MSK cluster |

<!-- END_TF_DOCS -->
