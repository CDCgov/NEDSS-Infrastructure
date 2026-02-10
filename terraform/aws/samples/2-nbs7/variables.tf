# Terraform Variable initialization-------------------------------
#  Description:
#   The variables defined in this file are required to be input 
#   into the provided modules. If there is NO default value,
#   please provide a value in terraform.tfvars.
#
#-----------------------------------------------------------------

# Non-module specific variables-----------------------------------
variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Map(string) of tags to add to created resources"
  type        = map(string)
}

variable "domain_name" {
  description = "Domain name associated with an AWS public hosted zone in current account? (e.g. nbspreview.com)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}
#-----------------------------------------------------------------

#EKS Variables----------------------------------------------------
variable "aws_role_arn" {
  description = "AWS IAM Role/USEr arn used to authenticate into the EKS cluster"
  type        = string
}

variable "readonly_role_arn" {
  description = "Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly"
  type        = string
  default     = null
}

variable "admin_role_arns" {
  description = "List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used."
  type        = list(string)
  default     = []
}

variable "readonly_role_arns" {
  description = "List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set."
  type        = list(string)
  default     = []
}

variable "eks_disk_size" {
  description = "Size of EKS volumes in GB"
  type        = number
  default     = 100
}

variable "external_cidr_blocks" {
  description = "List of cidr blocks to add to security groups, e.g. vpn, admin"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.external_cidr_blocks) >= 0
    error_message = "external_cidr_blocks must be a list of CIDR blocks"
  }
  validation {
    condition     = alltrue([for cidr in var.external_cidr_blocks : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr))])
    error_message = "Each entry in external_cidr_blocks must be a valid CIDR block"
  }
}

variable "eks_cluster_version" {
  description = "Version of eks cluster"
  type        = string
  default     = "1.32"
}

variable "eks_instance_type" {
  description = "Instance type to use in EKS cluster"
  type        = string
  default     = "m5.large"
}

variable "eks_desired_nodes_count" {
  description = "Number of EKS nodes desired"
  type        = number
  default     = 3
}

variable "eks_max_nodes_count" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 5
}

variable "eks_min_nodes_count" {
  description = "Minimum umber of EKS nodes"
  type        = number
  default     = 3
}

variable "deploy_argocd_helm" {
  description = "Do you wish to deploy ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "eks_allow_endpoint_public_access" {
  description = "Allow both public and private access to EKS api endpoint. If False, terraform must have access to AWS network containing EKS API."
  type        = bool
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available."
  type        = list(string)

  validation {
    condition     = length(var.kms_key_administrators) >= 0
    error_message = "kms_key_administrators must be a list of IAM ARNs"
  }
}
#-----------------------------------------------------------------

# MSK/Kafka Variables---------------------------------------------
variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
  default     = 100
}

variable "msk_environment" {
  description = "The environment, either 'development' which provisions 2 brokers in 2 different subnets or 'production' which provisions 3 brokers in 3 different subnets."
  type        = string

  validation {
    condition = (
      (var.msk_environment == "development" && length(data.aws_subnets.nbs7.ids) >= 2) ||
      (var.msk_environment == "production" && length(data.aws_subnets.nbs7.ids) >= 3)
    )
    error_message = "There is an insufficient number of subnets for the given MSK environment '${var.msk_environment}'. 'development' requires 2 subnets, 'production' requires 3 subnets."
  }
}
#-----------------------------------------------------------------

# Prometheus/Grafana Variables------------------------------------
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
#-----------------------------------------------------------------