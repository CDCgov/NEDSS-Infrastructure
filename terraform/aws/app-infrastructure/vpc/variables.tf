variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "name" {
  description = "Name of your VPC (an overwrite option to use a custom name)"  
  type        = string
  default     = ""
}

variable "cidr" {
    description = "CIDR block of your VPC"    
}

variable "azs" {
    description = "List of AWS availability zones in current region"
    type = list
}

variable "private_subnets" {
    description = "List of CIDR blocks for each private subnets to be created"
    type = list    
} 

variable "public_subnets" {
    description = "List of CIDR blocks for each private subnets to be created"
    type = list    
}

variable "create_igw" {
    description = "Create an internet gateway(requires public subnet)?"
    type = bool    
}

variable "enable_nat_gateway" {
    description = "Create NAT Gateway?"
    type = bool
}

variable "single_nat_gateway" {
    description = "Use a single NAT Gateway (low availability)?"
    type = bool
}

variable "one_nat_gateway_per_az" {
    description = "Use a single NAT Gateway for each availability zone?"
    type = bool
}

variable "enable_dns_hostnames" {
    description = "Should be true to enable DNS hostnames in the VPC"
    default = false
}
variable "enable_dns_support" {
    description = "Should be true to enable DNS support in the VPC"
    default = true
}
variable "manage_default_security_group" {
    description = "Should be true to adopt and manage default security group in the VPC"
    default = false
}
variable "manage_default_route_table" {
    description = "Should be true to adopt and manage default route table in the VPC"
    default = false
}
variable "manage_default_network_acl" {
    description = "Should be true to adopt and manage default network acl in the VPC"
    default = false
}
variable "map_public_ip_on_launch" {
    description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false`"
    default = false
}
