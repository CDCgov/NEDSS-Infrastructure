# Serial: 2024101502

#########################################################################################
# Common Variables
#########################################################################################
# Account variables
variable "target_account_id" {
  description = "The AWS account id where resources will be deployed, must have credentials in environment to run terraform"
  type        = string
}

variable "zone_id" {
  description = "Route53 Hosted Zone Id (default='')"
  type        = string
  default     = ""
}

variable "route53_url_name" {
  description = "URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com)"
  type        = string
}

variable "create_cert" {
  description = "Do you want to create a public AWS Certificate (if false, must provide certificate ARN)."
  type        = bool
}

variable "certificate_arn" {
  description = "If create_cert == false, provide a certificate_arn"
  type        = string
  default     = ""
}

variable "create_route53_hosted_zone" {
  description = "Do you want to create a public hosted zone?"
  type        = bool
  default     = false
}

# Domain
variable "domain_name" {
  description = "what will be the domain name? (e.g. nbspreview.com) "
  type        = string
}

variable "sub_domain_name" {
  description = "what is subdomain? (e.g. fts1)"
  type        = string
}

# NS for DNS
variable "hosted-zone-iam-arn" {
  description = "IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered. (Leave blank if same account)"
  type        = string
  default     = ""
}

variable "hosted-zone-id" {
  description = "Hosted Zone ID for the AWS hosted zone where the domain is registered."
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name used to store build artifacts"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "external_cidr_blocks" {
  description = "List of cidr blocks to add to security groups, e.g. vpn, admin"
  type        = list(any)
  default     = []
}

# is this still used? how is it used with external cidr blocks?
variable "shared_vpc_cidr_block" {
  description = "VPC CIDR block in shared services account"
  type        = string
}

variable "kms_arn_shared_services_bucket" {
  description = "KMS key arn used to encrypt shared services s3 bucket"
  type        = string
}
variable "nbs_db_dns" {
  description = "NBS database server DNS"
  type        = string
}

# cmoss - not sure if this is used by both ECS and modern?
variable "use_ecr_pull_through_cache" {
  description = "Set ecr pull through cache options (true/false)"
  type        = bool
  default     = false
}

# These may be uncommented if either NBS6 or NBS7 is not included
#variable "legacy_vpc_id" {
#  description = "The vpc used for legacy resources"
#  type = string
#}

#variable "modern_vpc_id" {
#  description = "The vpc used for modern resources"
#  type = string
#}

# End Common variables
#########################################################################################

