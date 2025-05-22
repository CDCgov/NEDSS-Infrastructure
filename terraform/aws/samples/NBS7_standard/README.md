## Terraform.tfvars configuration

| Parameter | Template Value | Description |
| --- | --- |
| target_account_id | EXAMPLE_ACCOUNT_ID | Account ID for the infrastructure deployment AWS Account ID |
| resource_prefix | EXAMPLE_RESOURCE_PREFIX | | Prefix for all the resources |
| modern-cidr | 10.OCTET2a.0.0/16 | A new CIDR range for modern vpc |
| modern-private_subnets | 10.OCTET2a.1.0/24, 10.OCTET2a.3.0/24 | A new modern private subnet cidr range |
| modern-public_subnets | 10.OCTET2a.2.0/24, 10.OCTET2a.4.0/24 | A new modern public subnet cidr range |
| legacy-cidr | 10.OCTET2b.0.0/16 | Existing VPC CIDR for NBS classic application |
| legacy-vpc-id | vpc-LEGACY-EXAMPLE | Existing NBS Classic application VPC ID |
| legacy_vpc_private_route_table_id | rtb-PRIVATE-EXAMPLE | Route table used by the subnets to which the database is attached |
| legacy_vpc_public_route_table_id | rtb-PUBLIC-EXAMPLE | route table used by the subnets the application server(s) and/or the application load balancer are attached to |
| aws_admin_role_name | AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE | Role IAM/SSO user assumes when logged in. Run: aws sts get-caller-identity to get the unique portion of the role |
| fluentbit_bucket_prefix | EXAMPLE-fluentbit-bucket | S3 bucket prefix for FluentBit |
| fluentbit_bucket_name | EXAMPLE-fluentbit-logs | S3 bucket that will be created to capture consolidated logs via FluentBit |

## Terraform.tf configuration

| Parameter | Template Value | Description |
| --- | --- |
| bucket | cdc-nbs-terraform-<EXAMPLE_ACCOUNT_NUM> | S3 bucket to store infrastructure artifacts |
| key | cdc-nbs-SITE_NAME-modern/infrastructure-artifacts | Path for the artifacts inside the s3 bucket, the buckets needs to exist before running terraform apply but the path will be created automatically |

## TEST

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |
