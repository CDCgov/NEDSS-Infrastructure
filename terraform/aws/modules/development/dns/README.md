# Terraform AWS Module: development/dns

## Description

This module is used to deploy and configure NBS7 development resources for AWS DNS services

## Module Details

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.hosted-zone-account"></a> [aws.hosted-zone-account](#provider\_aws.hosted-zone-account) | n/a |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_zones"></a> [zones](#module\_zones) | terraform-aws-modules/route53/aws//modules/zones | ~> 2.10 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_record.ns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.private_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for hosted zone (ex. dev-app.my-domain.com) | `string` | n/a | yes |
| <a name="input_legacy_vpc_id"></a> [legacy\_vpc\_id](#input\_legacy\_vpc\_id) | Legacy VPC Id | `string` | n/a | yes |
| <a name="input_nbs_db_dns"></a> [nbs\_db\_dns](#input\_nbs\_db\_dns) | CNAME for NBS DB host | `string` | n/a | yes |
| <a name="input_nbs_db_host_name"></a> [nbs\_db\_host\_name](#input\_nbs\_db\_host\_name) | Host name for RDS database instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | map(string) of tags to add to created hosted zone | `map(string)` | n/a | yes |
| <a name="input_hosted-zone-iam-arn"></a> [hosted-zone-iam-arn](#input\_hosted-zone-iam-arn) | IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered. | `string` | `""` | no |
| <a name="input_hosted-zone-id"></a> [hosted-zone-id](#input\_hosted-zone-id) | Hosted Zone ID for the AWS hosted zone where the domain is registered. (Blank indicates skipping creation of the NS record) | `string` | `""` | no |
| <a name="input_modern_vpc_id"></a> [modern\_vpc\_id](#input\_modern\_vpc\_id) | The ID of the modern VPC. Optional. | `string` | `null` | no |
| <a name="input_sub_domain_name"></a> [sub\_domain\_name](#input\_sub\_domain\_name) | Sub Domain name for hosted zone used to create NS record in Route53(ex. dev-app) | `string` | `""` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nbs_db_dns"></a> [nbs\_db\_dns](#output\_nbs\_db\_dns) | n/a |
| <a name="output_registered_domain_name"></a> [registered\_domain\_name](#output\_registered\_domain\_name) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->
