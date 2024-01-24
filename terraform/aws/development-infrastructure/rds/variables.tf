variable "resource_prefix" {
  description = "Resource prefix for resources created by this module"
  type        = string
}

variable "db_instance_type" {
  description = "Database instance type"
  type        = string
}

variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS isntance"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet Id to be used when creating RDS"
  type        = list(any)
}

variable "apply_immediately" {
  type = bool
  default = false
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type = bool
  default = false
}


variable "shared_vpc_cidr_block" {
  description = "VPC CIDR block in shared services account"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}
