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
  type = number
  default = 100
}

variable "eks_instance_type" {
  type = string
}

variable "eks_desired_nodes_count" {
  type    = number
  default = 3
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
  type    = string
}
#-----------------------------------------------------------------