# Terraform AWS Module: development/dns

## Description

This module is used to deploy and configure NBS7 development resources for AWS DNS services

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                                                                         | Version |
| ------------------------------------------------------------------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                                                             | n/a     |
| <a name="provider_aws.hosted-zone-account"></a> [aws.hosted-zone-account](#provider_aws.hosted-zone-account) | n/a     |

## Modules

| Name                                               | Source                                           | Version |
| -------------------------------------------------- | ------------------------------------------------ | ------- |
| <a name="module_zones"></a> [zones](#module_zones) | terraform-aws-modules/route53/aws//modules/zones | ~> 2.10 |

## Resources

| Name                                                                                                                            | Type     |
| ------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_route53_record.ns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)      | resource |
| [aws_route53_record.private_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name                                                                                       | Description                                                                                                                 | Type          | Default | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- | ------------- | ------- | :------: |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name)                         | Domain name for hosted zone (ex. dev-app.my-domain.com)                                                                     | `string`      | n/a     |   yes    |
| <a name="input_hosted-zone-iam-arn"></a> [hosted-zone-iam-arn](#input_hosted-zone-iam-arn) | IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered.                           | `string`      | `""`    |    no    |
| <a name="input_hosted-zone-id"></a> [hosted-zone-id](#input_hosted-zone-id)                | Hosted Zone ID for the AWS hosted zone where the domain is registered. (Blank indicates skipping creation of the NS record) | `string`      | `""`    |    no    |
| <a name="input_legacy_vpc_id"></a> [legacy_vpc_id](#input_legacy_vpc_id)                   | Legacy VPC Id                                                                                                               | `string`      | n/a     |   yes    |
| <a name="input_modern_vpc_id"></a> [modern_vpc_id](#input_modern_vpc_id)                   | The ID of the modern VPC. Optional.                                                                                         | `string`      | `null`  |    no    |
| <a name="input_nbs_db_dns"></a> [nbs_db_dns](#input_nbs_db_dns)                            | CNAME for NBS DB host                                                                                                       | `string`      | n/a     |   yes    |
| <a name="input_nbs_db_host_name"></a> [nbs_db_host_name](#input_nbs_db_host_name)          | Host name for RDS database instance                                                                                         | `string`      | n/a     |   yes    |
| <a name="input_sub_domain_name"></a> [sub_domain_name](#input_sub_domain_name)             | Sub Domain name for hosted zone used to create NS record in Route53(ex. dev-app)                                            | `string`      | `""`    |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                              | map(string) of tags to add to created hosted zone                                                                           | `map(string)` | n/a     |   yes    |

## Outputs

| Name                                                                                                  | Description |
| ----------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_nbs_db_dns"></a> [nbs_db_dns](#output_nbs_db_dns)                                     | n/a         |
| <a name="output_registered_domain_name"></a> [registered_domain_name](#output_registered_domain_name) | n/a         |
| <a name="output_zone_id"></a> [zone_id](#output_zone_id)                                              | n/a         |

<!-- END_TF_DOCS -->
