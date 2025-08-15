## Terraform.tfvars Dictionary Table

| Parameter | Template Value | Description | Required |
| --- | --- | --- | --- |
| target_account_id | EXAMPLE_ACCOUNT_ID | Account ID for the infrastructure deployment AWS Account ID | Y |
| resource_prefix | EXAMPLE_RESOURCE_PREFIX | Prefix for all the resources | Y |
| modern-cidr | 10.OCTET2a.0.0/16 | A new CIDR range for modern vpc | Y |
| modern-private_subnets | 10.OCTET2a.1.0/24, 10.OCTET2a.3.0/24 | A new modern private subnet cidr range | Y |
| modern-public_subnets | 10.OCTET2a.2.0/24, 10.OCTET2a.4.0/24 | A new modern public subnet cidr range | Y |
| legacy-cidr | 10.OCTET2b.0.0/16 | Existing VPC CIDR for NBS classic application | Y |
| legacy-vpc-id | vpc-LEGACY-EXAMPLE | Existing NBS Classic application VPC ID | Y |
| legacy_vpc_private_route_table_id | rtb-PRIVATE-EXAMPLE | Route table used by the subnets to which the database is attached | Y |
| legacy_vpc_public_route_table_id | rtb-PUBLIC-EXAMPLE | route table used by the subnets the application server(s) and/or the application load balancer are attached to | Y |
| tags.Environment | EXAMPLE_ENVIRONMENT | Environment where the infrastructure will be deployed | Y |
| aws_admin_role_name | aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE | Role IAM/SSO user assumes when logged in. Run: aws sts get-caller-identity to get the unique portion of the role | Y |
| readonly_role_name | aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_EXAMPLE_ROLE | optional role to authenticate into the EKS cluster for ReadOnly, leave empty "" if not needed | Y |
| fluentbit_bucket_prefix | EXAMPLE-fluentbit-bucket | S3 bucket prefix for FluentBit | Y |
| fluentbit_bucket_name | EXAMPLE-fluentbit-logs | S3 bucket that will be created to capture consolidated logs via FluentBit | Y |

## Terraform.tf Dictionary Table

| Parameter | Template Value | Description |
| --- | --- | --- |
| bucket | cdc-nbs-terraform-<EXAMPLE_ACCOUNT_NUM> | S3 bucket to store infrastructure artifacts | Y |
| key | cdc-nbs-SITE_NAME-modern/infrastructure-artifacts | Path for the artifacts inside the s3 bucket, the buckets needs to exist before running terraform apply but the path will be created automatically | Y |
