# Terraform Variable initialization-------------------------------
#  Description:
#   The variables defined in this file are required to be input 
#   into the provided modules. If there is NO default value,
#   please provide a value in inputs.tfvars.
#
#-----------------------------------------------------------------

# Non-module specific variables-----------------------------------
variable "target_account_id" {
  type = string
}

variable "resource_prefix" {
  type = string
}


variable "tags" {
  type = map(string)
}
#-----------------------------------------------------------------

# Modernization VPC Variables-------------------------------------
variable "modern-cidr" {}

variable "modern-azs" {}

variable "modern-private_subnets" {
  type = list(any)
}

variable "modern-public_subnets" {
  type = list(any)
}

# VPC option defaults
variable "modern-create_igw" {
  type    = bool
  default = true
}

variable "modern-enable_nat_gateway" {
  type    = bool
  default = true
}

variable "modern-single_nat_gateway" {
  type    = bool
  default = true
}

variable "modern-one_nat_gateway_per_az" {
  type    = bool
  default = false
}

variable "modern-enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "modern-enable_dns_support" {
  type    = bool
  default = true
}
#-----------------------------------------------------------------

# Legacy VPC Variables (Existing values)--------------------------
variable "legacy-vpc-id" {}

variable "legacy-cidr" {}

variable "legacy_vpc_private_route_table_id" {}

variable "legacy_vpc_public_route_table_id" {}
#-----------------------------------------------------------------


#EKS Variables----------------------------------------------------
variable "eks_disk_size" {
  type    = number
  default = 100
}

variable "eks_instance_type" {
  type = string
}

variable "eks_desired_nodes_count" {
  type    = number
  default = 4
}

variable "eks_max_nodes_count" {
  type    = number
  default = 5
}

variable "eks_min_nodes_count" {
  type    = number
  default = 3
}

variable "aws_admin_role_name" {
  type = string
}

variable "readonly_role_name" {
  description = "Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly"
  type        = string
  default     = "" # leave empty if not needed
}
#-----------------------------------------------------------------

# S3 buckets -----------------------------------------------------
variable "fluentbit_bucket_prefix" {
  type = string
}
#-----------------------------------------------------------------

# MSK/Kafka Variables---------------------------------------------
variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
  default     = 20
}

###########################################################
# Serial: 2024042601


variable "fluentbit_force_destroy_log_bucket" {
  description = "If true, the log bucket will be deleted on terraform destroy with all contents. Defaults to `false`"
  type        = bool
  default = false
}

variable "use_ecr_pull_through_cache" {
  type    = bool
  default = false
}

variable "external_cidr_blocks" {
  type    = list(any)
  default = []
}

variable "eks_allow_endpoint_public_access" {
  description = "Allow both public and private access to EKS api endpoint"
  type        = bool
  default     = true
}

variable "create_prometheus_vpc_endpoint" {
  description = "Create Prometheus VPC endpoint and security group?"
  type        = bool
  default     = true
}

variable "create_grafana_vpc_endpoint" {
  description = "Create Grafana VPC endpoint and security group?"
  type        = bool
  default     = true
}

variable "observability_namespace_name" {
  description = "namespace for fluentbit, prometheus, grafana etc"
  type        = string
  default     = "observability"
}

variable "fluentbit_bucket_name" {
  description = "name of fluentbit logs bucket, must be unique so include account number"
  type        = string
}

variable "deploy_argocd_helm" {
  description = "Do you wish to deploy ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "false"
}
