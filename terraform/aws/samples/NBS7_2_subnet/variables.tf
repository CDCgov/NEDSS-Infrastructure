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
# variable "modern-cidr" {}

# variable "modern-azs" {}

# variable "modern-private_subnets" {
#   type = list(any)
# }

# variable "modern-public_subnets" {
#   type = list(any)
# }

# # VPC option defaults
# variable "modern-create_igw" {
#   type    = bool
#   default = true
# }

# variable "modern-enable_nat_gateway" {
#   type    = bool
#   default = true
# }

# variable "modern-single_nat_gateway" {
#   type    = bool
#   default = true
# }

# variable "modern-one_nat_gateway_per_az" {
#   type    = bool
#   default = false
# }

# variable "modern-enable_dns_hostnames" {
#   type    = bool
#   default = true
# }

# variable "modern-enable_dns_support" {
#   type    = bool
#   default = true
# }
#-----------------------------------------------------------------

# Legacy VPC Variables (Existing values)--------------------------
# variable "legacy-vpc-id" {}

# variable "legacy-cidr" {}

# variable "legacy_vpc_private_route_table_id" {}

# variable "legacy_vpc_public_route_table_id" {}
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
  default = 2
}

variable "eks_max_nodes_count" {
  type    = number
  default = 5
}

variable "eks_min_nodes_count" {
  type    = number
  default = 2
}

variable "aws_admin_role_name" {
  type = string
}


variable "sso_admin_role_name" {
  type = string
}

variable "use_ecr_pull_through_cache" {  
  type        = bool
  default     = false
}

variable "external_cidr_blocks" {  
  type        = list
  default     = []
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
#-----------------------------------------------------------------

# RDS Variables --------------------------------------------------
variable "db_instance_type" {
  description = "Database instance type"
  type        = string
}

variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS isntance"
  type        = string
}

# variable "private_subnet_ids" {
#   description = "Subnet Id to be used when creating RDS"
#   type        = list(any)
# }

# variable "apply_immediately" {
#   type = bool
#   default = false
# }

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type = bool
  default = true
}

# variable "vpc_id" {
#   description = "VPC ID of virtual private cloud"
#   type        = string
# }

variable "ingress_vpc_cidr_blocks" {  
  type        = string
  default     = ""
}
#-----------------------------------------------------------------

# NBS6 Variables --------------------------------------------------
variable ecs_private_ipv4_address {
  type        = string
}

variable "docker_image" {
  description = "Docker Image for Classic NBS"
  type        = string
  default = ""
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
#-----------------------------------------------------------------