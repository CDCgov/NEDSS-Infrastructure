variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "name" {
  description = "Name of the EKS cluster (an overwrite option to use a custom name)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The AWS VPC ID to deploy in which to deploy the cluster"
  type        = string
}

variable "subnets" {
  description = "List of the AWS private subnets ids associated with the supplied vpc_id to deploy in which to deploy the cluster"
  type        = list(string)
}

variable "instance_type" {
  description = "The AWS EC2 instance type with which to spin up EKS nodes"
  type        = string
  default     = "m5.large"
}

variable "aws_role_arn" {
  description = "AWS IAM Role arn used to authenticate into the EKS cluster"
  type        = string
}

variable "sso_role_arn" {
  description = "AWS SSO IAM Role arn used to authenticate into the EKS cluster"
  type        = string
}

######
variable "readonly_role" {
    description = "AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly"
  type        = string
}
#######
variable "cluster_version" {
  description = "Version of the AWS EKS cluster to provision"
  default = "1.32"
}

variable "desired_nodes_count" {
  description = "Base number of EKS nodes to be maintained by the autoscaling group"
  type        = number
  default     = 3
}

variable "max_nodes_count" {
  description = "Maximum number of EKS nodes allowed by the autoscaling group"
  type        = number
  default     = 5
}

variable "min_nodes_count" {
  description = "Minimum number of EKS nodes allowed by the autoscaling group"
  type        = number
  default     = 3
}

variable "ebs_volume_size" {
  description = "EBS volume size backing each EKS node on creation"
  type        = number
  default     = 100
}

variable "deploy_argocd_helm" {
  description = "Do you wish to bootstrap ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "argocd_version" {
  description = "Version of ArgoCD with which to bootstrap EKS cluster"
  type        = string
  default     = "5.23.3"
}

variable "deploy_istio_helm" {
  description = "Do you wish to bootstrap Istio with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "istio_version" {
  description = "Version of Istio with which to bootstrap EKS cluster"
  type        = string
  default     = "1.17.2"
}

# variable "observability_namespace" {
#   description = "Name for the observability namespace with the EKS cluster to be created"
#   type        = string
#   default     = "observability"
# }

# variable "observability_labels" {
#   description = "Labels to add to observability namespace"
#   type        = map(string)
#   default     = null

#   # sample label
#   # default     = {
#   #   my_label_key = "my_label_value"
#   # }
# }

variable "use_ecr_pull_through_cache" {
  description = "Create and use ECR pull through caching for bootstrapped helm charts"
  type        = bool
  default     = false
}

variable "allow_endpoint_public_access" {
  description = "Allow both public and private access to EKS api endpoint"
  type        = bool
  default     = false
}

variable "external_cidr_blocks" {
  description = "A list of IAM ARNs for those who will have full key permissions (kms:*)"
  type        = list
  default     = []
}

variable "kms_key_owners" {
  description = "List of CIDR blocks (ex. 10.0.0.0/32) to allow access to eks cluster API"
  type        = list
  default     = []
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list
  default     = []
}

variable "kms_key_enable_default_policy" {
  description = "Specifies whether to enable the default key policy"
  type        = bool
  default     = false
}




