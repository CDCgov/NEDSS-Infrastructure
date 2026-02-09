# Terraform Variable initialization-------------------------------
#  Description:
#   The variables defined in this file are required to be input 
#   into the provided modules. If there is NO default value,
#   please provide a value in terraform.tfvars.
#
#-----------------------------------------------------------------

variable "resource_prefix" {
  description = "Prefix for resource names"
  type = string
}

# VPC variables
variable "cidr" {
  description = "CIDR block of your VPC"
}

variable "azs" {
  description = "List of AWS availability zones in current region"
  type        = list(any)
}

variable "private_subnets" {
  description = "List of CIDR blocks for each private subnets to be created"
  type        = list(any)
}

variable "public_subnets" {
  description = "List of CIDR blocks for each private subnets to be created"
  type        = list(any)
}

# VPC option defaults
variable "create_igw" {
  description = "Create an internet gateway(requires public subnet)?"
  type        = bool
  default = true
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway?"
  type        = bool
  default = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (low availability)?"
  type        = bool
  default = true
}

variable "one_nat_gateway_per_az" {
  description = "Use a single NAT Gateway for each availability zone?"
  type        = bool
  default = false
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type    = bool
  default = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type    = bool
  default = true
}
#-----------------------------------------------------------------