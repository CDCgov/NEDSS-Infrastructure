# Terraform Deployment of the environment

## Description

This package is used to deploy and configure ...



## Inputs

Below are the input parameter variables the environement:


Domain name:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| domain_name | string |  | Domain name for hosted zone (ex. dev-app.my-domain.com) |
| sub_domain_name | string |  | Sub Domain name for hosted zone used to create NS record in Route53(ex. dev-app) |
| create_route53_hosted_zone | boolean | true | Do you want to create a public hosted zone? |


Modernization Infrastructure VPC:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| modern-name | string |  | Name of your VPC |
| modern-cidr | string |  | CIDR block of your VPC |
| modern-azs | list |  | List of AWS availability zones in current region |
| modern-private_subnets | list |  | List of CIDR blocks for each private subnets to be created |
| modern-public_subnets | list |  | List of CIDR blocks for each public subnets to be created |
| modern-create_igw | boolean | `true` | Create an internet gateway(requires public subnet)? |
| modern-enable_nat_gateway | boolean | `true` | Create NAT Gateway? |
| modern-single_nat_gateway | boolean | `true` | Use a single NAT Gateway (low availability)? |
| modern-one_nat_gateway_per_az | boolean | `false` | Use a single NAT Gateway for each availability zone? |
| modern-enable_dns_hostnames | boolean | `true` | Should be true to enable DNS hostnames in the VPC |
| modern-enable_dns_support | boolean | `true` | Should be true to enable DNS support in the VPC |


Legacy Infrastructure VPC:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| legacy-name | string |  | Name of your VPC |
| legacy-cidr | string |  | CIDR block of your VPC |
| legacy-azs | list |  | List of AWS availability zones in current region |
| legacy-private_subnets | list |  | List of CIDR blocks for each private subnets to be created |
| legacy-public_subnets | list |  | List of CIDR blocks for each public subnets to be created |
| legaacy-create_igw | boolean | `true` | Create an internet gateway(requires public subnet)? |
| legacy-enable_nat_gateway | boolean | `true` | Create NAT Gateway? |
| legacy-single_nat_gateway | boolean | `true` | Use a single NAT Gateway (low availability)? |
| legacy-one_nat_gateway_per_az | boolean | `false` | Use a single NAT Gateway for each availability zone? |
| legacy-enable_dns_hostnames | boolean | `true` | Should be true to enable DNS hostnames in the VPC |
| legacy-enable_dns_support | boolean | `true` | Should be true to enable DNS support in the VPC |


Tags:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| Project | string |  | The name of the project |
| Environment | string | `development` | The environment, either 'development' or 'production' |
| Owner | string | true | The name of the owner |
| Terraform | boolean | true | Is it created by Terraform? |


Modern Variables:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| eks_disk_size | string |  | Size of EKS volumes in GB |
| eks_instance_types | list |  | Instance type to use in EKS cluster |


Classic EC2 Instance:
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| ami | string |  | AMI for EC2 instance |
| instance_type | string |  | Instance type for EC2 instance |
| ec2_key_name | string |  | EC2 key name to manage instance |
| shared_vpc_cidr_block | string |  | VPC CIDR block in shared services account |
| db_instance_type | string |  | Databae instance type |
| db_snapshot_identifier | string |  | Database snapshot to use for RDS instance |
| route53_url_name | string |  | URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com) |
| create_cert | string |  | Do you want to create a public AWS Certificate (if false, must provide certificate ARN) |
| artifacts_bucket_name | string |  | S3 bucket name used to store build artifacts |
| deployment_package_key | string |  | Deployment package S3 key for NBS application |
| nbs_db_dns | string |  | NBS database server DNS |


Amazon Service for Kafka (MSK):
| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| environment | string | `development` | The environment, either 'development' or 'production' |
| msk_ebs_volume_size | number | `20` | EBS volume size for the MSK broker nodes in GB |
