# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for AWS DNS purposes.

## Values

Below are the available Variables contained within this DNS module:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| domain_name | string |  | Domain name for hosted zone |
| hosted-zone-iam-arn | string | "" | IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered. |
| hosted-zone-id | string | "" | Hosted Zone ID for the AWS hosted zone where the domain is registered. (Blank indicates skipping creation of the NS record) |
| legacy_vpc_id | string |  | Legacy VPC ID |
| modern_vpc_id | string |  | Modern VPC ID |
| nbs_db_dns | string |  | CNAME for NBS DB host |
| nbs_db_host_name | string |  | Host name for RDS database instance |
| sub_domain_name | string |  | Sub Domain name for hosted zone used to create NS record in Route53(ex. dev-app) |
| tags | map(string) |  | map(string) of tags to add to created hosted zone |

Below are the available Outputs contained within this DNS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| zone_id |  | `module.zones.route53_zone_zone_id` | Route 53 zone id |
| registered_domain_name |  | `var.domain_name` | Domain name |
| nbs_db_dns |  | `${var.nbs_db_dns}.private-${var.domain_name}` | Database DNS |
