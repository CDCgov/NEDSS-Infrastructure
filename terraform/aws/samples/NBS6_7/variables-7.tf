# Serial: 2024121601

#########################################################################################
# Modernization VPC Variables
#########################################################################################
#variable "modern-name" {
#  description = "A default name for all modern resources, may use resource_prefix instead of this"
#  type        = string
#  default     = "cdc-nbs-modern-vpc"
#}

variable "modern-cidr" {
  description = "CIDR for modern VPC"
  type        = string
}

variable "modern-azs" {
  description = "A list of AZs for modern resources"
  type        = list(any)
}

variable "modern-private_subnets" {
  description = "A list of private subnets for modern resources"
  type        = list(any)
}

variable "modern-public_subnets" {
  description = "A list of public subnets for modern resources"
  type        = list(any)
}

variable "modern-create_igw" {
  description = "Create an internet gateway for the modern VPC (true/false)"
  type        = bool
  default     = true
}

variable "modern-enable_nat_gateway" {
  description = "enable nat gateway for modern VPC?  (true/false)"
  type        = bool
  default     = true
}

# can this be combined with next variable?
variable "modern-single_nat_gateway" {
  description = "enable single nat gateway for all AZs on modern VPC?  (true/false)"
  type        = bool
  default     = true
}

variable "modern-one_nat_gateway_per_az" {
  description = "enable one nat gateway per az on modern VPC?  (true/false)"
  type        = bool
  default     = false
}

variable "modern-enable_dns_hostnames" {
  description = "Enable modern dns hostnames? (true/false) "
  type        = bool
  default     = true
}

variable "modern-enable_dns_support" {
  description = "Enable modern dns support? (true/false) "
  type        = bool
  default     = true
}

# MSK variables
variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
  default = 20
}
variable "environment" {
  description = "The environment, either 'development' or 'production'"
  default     = "development"
}
# end MSK variables


# EKS variables
variable "aws_admin_role_name" {
  description = "IAM role name for EKS sso arn"
  type        = string
  default     = ""
}

variable "sso_admin_role_name" {
  description = "IAM role name for EKS sso arn"
  type        = string
  default     = ""
}

variable "eks_disk_size" {
  description = "Size of EKS volumes in GB"
  type        = number
  default     = "20"
}

variable "eks_instance_type" {
  description = "Instance type to use in EKS cluster"
  type        = string
  default     = "m5.large"
}

variable "eks_desired_nodes_count" {
  description = "Number of EKS nodes desired (default = 3)"
  type        = number
  default     = 3
}

variable "eks_max_nodes_count" {
  description = "Maximum number of EKS nodes (default = 5)"
  type        = number
  default     = 5
}

variable "eks_min_nodes_count" {
  description = "Number of EKS nodes desired (default = 2)"
  type        = number
  default     = 2
}

variable "deploy_istio_helm" {
  description = "Do you wish to bootstrap Istio with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "deploy_argocd_helm" {
  description = "Do you wish to deploy ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "true"
  # SAMPLES
  # default     = "false"
}
variable "eks_allow_endpoint_public_access" {
  description = "Allow both public and private access to EKS api endpoint"
  type        = bool
  default     = true
}
# end EKS variables

# observability variables
variable "observability_namespace_name" {
  description = "namespace for fluentbit, prometheus, grafana etc"
  type        = string
  default     = "observability"
}

# instead of doing this we will build fluentbit bucket specific resource_prefix with
# resource_prefix and append -fluentbit-logs-
# remove this block later if we want to simplify file
#variable "fluentbit_bucket_name" {
# description = "name of fluentbit logs bucket, must be unique so include account number"
# type        = string
#}
#variable "fluentbit_bucket_prefix" {
#  description = "Prefix for fluentbit bucket, module will append unique id"
#  type        = string
#}

variable "fluentbit_force_destroy_log_bucket" {
  description = "If true, the log bucket will be deleted on terraform destroy with all contents. Defaults to `false`"
  type        = bool
  default     = false
}

variable "create_prometheus_vpc_endpoint" {
  description = "Create Prometheus VPC endpoint and security group?"
  type        = bool
  default     = true
}

variable "grafana_workspace_name" {
  description = "The name of the Grafana workspace"
  type        = string
  default     = ""
}

variable "create_grafana_vpc_endpoint" {
  description = "Create Grafana VPC endpoint and security group?"
  type        = bool
  default     = true
}

# end observability variables

# synthetics variables
# synthetics monitoring, disabled by default since it is tricky with
# pipeline
# this is defined outside the pipeline (at cli?)
variable "synthetics_canary_create" {
  type        = bool
  description = "Create canary required resources?"
  default     = false
}

variable "synthetics_canary_bucket_name" {
  description = "bucket name for synthetics output"
  type        = string
  default     = ""
}

variable "synthetics_canary_url" {
  description = "A URL to use for monitoring alerts"
  type        = string
  default     = ""
  # example = "https://app.EXAMPLE_SITE_NAME.nbspreview.com/nbs/login"
}

#variable "synthetics_canary_email_addresses" {
#  description = "A list of email addresses to use for monitoring alerts"
#  type        = list(string)
#  default     = ""
#}

# end synthetics variables

# End Modern variables
#########################################################################################

