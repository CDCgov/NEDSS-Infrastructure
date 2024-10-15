# Serial: 2024081302

#########################################################################################
# Common Variables
#########################################################################################

# Account variables
variable "target_account_id" {
  description = "The AWS account id where resources will be deployed, must have credentials in environment to run terraform"
  type        = string
}

#########################################################################################
# Modernization VPC Variables
# variable "modern-name" {
#   description = "A default name for all modern resources, may use resource_prefix instead of this"
#   type        = string
# }

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
}

variable "modern-enable_nat_gateway" {
  description = "enable nat gateway for modern VPC?  (true/false)"
  type        = bool
}

# can this be combined with next variable?
variable "modern-single_nat_gateway" {
  description = "enable single nat gateway for all AZs on modern VPC?  (true/false)"
  type        = bool
}

variable "modern-one_nat_gateway_per_az" {
  description = "enable one nat gateway per az on modern VPC?  (true/false)"
  type        = bool
}

variable "modern-enable_dns_hostnames" {
  description = "Enable modern dns hostnames? (true/false) "
  type        = bool
}

variable "modern-enable_dns_support" {
  description = "Enable modern dns support? (true/false) "
  type        = bool
}

#########################################################################################
# Legacy VPC Variables
#########################################################################################
# variable "legacy-name" {
#   description = "A default name for all classic resources, may use resource_prefix instead of this"
#   type        = string
# }

variable "legacy-cidr" {
  description = "CIDR for classic VPC"
  type        = string
}

variable "legacy-azs" {
  description = "A list of AZs for classic resources"
  type        = list(any)
}

variable "legacy-private_subnets" {
  description = "A list of private subnets for classic resources"
  type        = list(any)
}

variable "legacy-public_subnets" {
  description = "A list of public subnets for classic resources"
  type        = list(any)
}

variable "legacy-create_igw" {
  description = "Create an internet gateway for the classic VPC (true/false)"
  type        = bool
}

variable "legacy-enable_nat_gateway" {
  description = "enable nat gateway for legacy VPC?  (true/false)"
  type        = bool
  default     = true
}

# can this be combined with next variable?
variable "legacy-single_nat_gateway" {
  description = "enable single nat gateway for all AZs on legacy VPC?  (true/false)"
  type        = bool
  default     = true
}

variable "legacy-one_nat_gateway_per_az" {
  description = "enable one nat gateway per az on legacy VPC?  (true/false)"
  type        = bool
  default     = false
}

variable "legacy-enable_dns_hostnames" {
  description = "Enable legacy dns hostnames? (true/false) "
  type        = bool
  default     = true
}

variable "legacy-enable_dns_support" {
  description = "Enable legacy dns support? (true/false) "
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
##########################################################
# NBS container on ECS

variable "shared_services_accountid" {
  description = "Shared Services Account ID. Needed to pull from ECR"
  type        = string
  default     = ""
}

variable "deploy_on_ecs" {
  description = "Deploy Classic NBS on ECS?"
  type        = bool
  default     = false
}

variable "deploy_alb_dns_record" {
  description = "Deploy alb dns record"
  type        = bool
  default     = true
}

variable "docker_image" {
  description = "Docker Image for Classic NBS"
  type        = string
  default     = ""
}

variable "nbs_github_release_tag" {
  description = "Create URL and download Release Package. Default is always latest or Null"
  type        = string
  default     = "latest"
}

variable "ecs_cpu" {
  description = "Classic NBS ECS CPU Configuration"
  type        = string
  default     = "2048"
}

variable "ecs_memory" {
  description = "Classic NBS ECS Memory Configuration"
  type        = string
  default     = "8192"
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
  description = "Precreated EC2 key name to manage classic instance"
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

variable "artifacts_bucket_name" {
  description = "S3 bucket name used to store build artifacts"
  type        = string
}

variable "deployment_package_key" {
  description = "Deployment package S3 key for NBS application"
  type        = string
}

variable "nbs_db_dns" {
  description = "NBS database server DNS"
  type        = string
}

variable "kms_arn_shared_services_bucket" {
  description = "KMS key arn used to encrypt shared services s3 bucket"
  type        = string
}

variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
}

# variable "environment" {
#   description = "The environment, either 'development' or 'production'"
#   default     = "development"
# }

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# this may be unused with latest deployment file updates
# variable "classic_resource_prefix" {
#   type        = string
#   description = "Prefix for classic resource names"
#   #default     = "cdc-nbs-legacy"
#   default = "cdc-nbs-classic"
# }

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
}

variable "eks_instance_type" {
  description = "Instance type to use in EKS cluster"
  type        = string
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

# variable "synthetics_canary_bucket_name" {
#   description = "bucket name for synthetics output"
#   type        = string
# }

# variable "synthetics_canary_url" {
#   description = "A URL to use for monitoring alerts"
#   type        = string
# }

# # this is defined outside the pipeline (at cli?)
# variable "synthetics_canary_create" {
#   type        = bool
#   description = "Create canary required resources?"
#   default     = false
# }

#variable "synthetics_canary_email_addresses" {
#  description = "A list of email addresses to use for monitoring alerts"
#  type        = list(string)
#}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = false
}

# variable "grafana_workspace_name" {
#   description = "The name of the Grafana workspace"
#   type        = string
# }

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are `application` or `network`. The default value is `application`"
  type        = string
  default     = "application"
}

variable "load_balancer_internal" {
  description = "If true, the LB will be internal. Defaults to `true`"
  type        = bool
  default     = true
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

variable "use_ecr_pull_through_cache" {
  description = "Set ecr pull through cache options (true/false)"
  type        = bool
  default     = false
}

variable "external_cidr_blocks" {
  description = "List of cidr blocks to add to security groups, e.g. vpn, admin"
  type        = list(any)
  default     = []
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

#variable "legacy_vpc_id" {
#  description = "The vpc used for legacy resources"
#  type = string
#}

#variable "modern_vpc_id" {
#  description = "The vpc used for modern resources"
#  type = string
#}

# we can disable user data if needed
variable "ec2_enable_user_data" {
  type    = bool
  default = true
}



# variable "aws_role_arn" {
#   description = "AWS IAM Role arn used to authenticate into the EKS cluster"
#   type        = string
# }

# variable "sso_role_arn" {
#   description = "AWS SSO IAM Role arn used to authenticate into the EKS cluster"
#   type        = string
# }