# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respective AWS environment using Terraform. The below module is used for NBS Legacy purposes.

## Values

Below are the available Variables contained within this NBS Legacy module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| artifacts_bucket_name | string |  | S3 bucket name used to store build artifacts |
| ami | string |  | AMI for EC2 instance |
| certificate_arn | string | `""` | If create_creat_cert == `false`, provide a certificate_arn |
| create_cert | boolean | `false` | Do you want to create a public AWS Certificate (if `false` (default), must provide certificate ARN) |
| db_instance_type | string |  | Database instance type |
| db_snapshot_identifier | string |  | Database snapshot to use for RDS instance |
| deployment_package_key | string |  | NBS database server dns |
| ec2_key_name | string |  | EC2 key pair to manage instance |
| domain_name | string |  | Domain name for hosted zone |
| instance_type | string |  | AMI for EC2 instance |
| kms_arn_shared_services_bucket | string |  | KMS key arn used to encrypt shared services within S3 bucket |
| legacy_resource_prefix | string |  | Legacy resource prefix for resources created by this module |
| legacy_vpc_id | string |  | Legacy VPC ID |
| modern_vpc_id | string |  | Modern VPC ID |
| nbs_db_dns | string |  | NBS database server dns |
| private_subnet_ids | list |  | Subnet ID to be used when creating EC2 instance |
| public_subnet_ids | list |  | Subnet ID to be used when creating ALB |
| route53_url_name | string |  | URL name for Classic App as an A record in route53 (ex. `app-dev.my-domain.com`) |
| shared_vpc_cidr_block | string |  | VPC CIDR block in shared services account |
| tags | map(string) |  | map(string) of tags to add to created hosted zone |
| daily_stop_nbs6 | map(string) |  default = {<br>&nbsp; enabled = "true" <br>&nbsp; nbs_stop_time = "00:00:00am"<br>} | Map(string) of detailing whether to stop nbs6 daily and at what server time. |
| windows_scheduled_tasks | string | "ELRImporter.bat,, 6am, 0, 0, 2; MsgOutProcessor.bat,, 8pm, 0, 0 , 2; UserProfileUpdateProcess.bat, retired\\, 12am, 1, 0, 0; DeDuplicationSimilarBatchProcess.bat, retired\\, 7pm, 1, 0 , 0; covid19ETL.bat,, 5am, 1, 0 , 0;" | Scheduled tasks in semicolon-separated list providing, note the trailing ';' - filename,scriptPathFromWorkDir,startTime,frequencyDays,frequencyHours,frequencyMinutes; |
| zone_id | string |  | Route53 Hosted Zone ID |

Below are the available Outputs contained within this DNS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| nbs_app_alb |  | `module.alb.lb_dns_name` | NBS Application DNS name |
| nbs_db_address |  | `module.db.db_instance_address` | NBS Database Instance Address |
