# Serial: 2023080201

# Account variables
variable "target_account_id" {
  type = string
}

# Modernization VPC Variables
variable "modern-name" {
  
}

variable "modern-cidr" {
  
}

variable "modern-azs" {
  
}

variable "modern-private_subnets" {
  type = list
}

variable "modern-public_subnets" {
  type = list
}

variable "modern-create_igw" {
  type = bool
}

variable "modern-enable_nat_gateway" {
  type = bool
}

variable "modern-single_nat_gateway" {
  type = bool
}

variable "modern-one_nat_gateway_per_az" {
  type = bool
}

variable "modern-enable_dns_hostnames" {
  type = bool
}

variable "modern-enable_dns_support" {
  type = bool
}

# Legacy VPC Variables
variable "legacy-name" {
  
}

variable "legacy-vpc-id" {
  
}
variable "legacy-cidr" {
  
}

variable "legacy-azs" {
  type = list
}

variable "legacy-private_subnets" {
  type = list
}

variable "legacy-public_subnets" {
  type = list
}
variable "legacy_vpc_private_route_table_id" {
}

variable "legacy_vpc_public_route_table_id" {
}

variable "legacy-create_igw" {
  type = bool
}

variable "legacy-enable_nat_gateway" {
  type = bool
}

variable "legacy-single_nat_gateway" {
 type = bool
}

variable "legacy-one_nat_gateway_per_az" {
  type = bool
}

variable "legacy-enable_dns_hostnames" {
  type = bool
}

variable "legacy-enable_dns_support" {
  type = bool
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)  
}

variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instance"
  type        = string
}

variable "shared_vpc_cidr_block" {
  description = "VPC CIDR block in shared services account"
  type        = string
}

variable "db_instance_type" {
  description = "Databae instance type"
  type        = string
}

variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS instance"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key name to manage instance"
  type        = string
} 

variable "zone_id" {
  description = "Route53 Hosted Zone Id (default='')"
  type = string
  default = ""
}

variable "route53_url_name" {
  description = "URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com)"
  type = string  
}

variable "create_cert" {
  description = "Do you want to create a public AWS Certificate (if false, must provide certificate ARN)."
  type = bool
}

variable "certificate_arn" {
  description = "If create_cert == false, provide a certificate_arn"
  type = string
  default = ""  
}

variable "create_route53_hosted_zone" {
  description = "Do you want to create a public hosted zone?"
  type = bool
  default = false
}

# Domain
variable "domain_name" {
  type = string  
}

variable "sub_domain_name" {
  type = string  
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name used to store build artifacts"
  type = string
  
}

variable "deployment_package_key" {
  description = "Deployment package S3 key for NBS application"
  type = string
  
}

variable "nbs_db_dns" {
  description = "NBS database server DNS"
  type = string
  
}

variable "eks_disk_size" {
  description = "Size of EKS volumes in GB"
  type        = number 
}

variable "eks_instance_types" {
  description = "Instance type to use in EKS cluster"
  type        = list 
}

#variable "argo_repo_login_data" {
#  description = "pass stringData to set up argocd connection with repo see https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/"
#  type = map(string) 
#}

variable "kms_arn_shared_services_bucket" {
  description = "KMS key arn used to encrypt shared services s3 bucket"
  type = string
}

#variable "msk_security_groups" {
#  description = "A list of security groups to use for the MSK cluster"
#  type        = list(string)
#}
#variable "msk_subnet_ids" {
#  description = "A list of subnets to use for the MSK cluster"
#  type        = list(string)
#}
variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
}
#variable "msk_region" {
#  description = "The AWS region to deploy MSK resources in"
#  type        = string
#}

variable "environment" {
  description = "The environment, either 'development' or 'production'"
  default     = "development"
}

#variable "sso_arn" {}

variable "aws_admin_role_name" {
  description = "IAM role name for EKS sso arn"
  type = string
  default = ""
}

# NS for DNS
variable "hosted-zone-iam-arn" {
  description = "IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered. (Leave blank if same account)"
  type = string
  default = ""
}
variable "hosted-zone-id" {
  description = "Hosted Zone ID for the AWS hosted zone where the domain is registered."
  type = string
}

#variable "synthetics_canary_email_addresses" {
#  description = "A list of email addresses to use for monitoring alerts"
#  type        = list(string)
#}
#variable "synthetics_canary_url" {
#  description = "A URL to use for monitoring alerts"
#  type        = string
#}
#variable "synthetics_canary_bucket_prefix" {
#  description = "prefix of bucket name for synthetics output"
#  type        = string
#}

