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
  description = "Subnet Ids to be used when creating RDS"
  type        = list(any)
}

variable "apply_immediately" {
  description = "Apply db changes immediately by default"
  type = bool
  default = false
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type = bool
  default = false
}

variable "app_security_group_id" {
  description = "Security group id of NBS6 instance to allow traffic into RDS"
  type = string
  default = null
}

variable "ingress_vpc_cidr_blocks" {
  description = "CSV of CIDR blocks which will have access to RDS instance"
  type        = string
  default = ""
}

variable "vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}

variable "parameter_group_name" {
  description = "Name of the parameter group"
  type        = string
  default     = "custom-db-parameter-group"
}

variable "parameter_group_description" {
  description = "Description for the parameter group"
  default     = "sql server se 15.0 custom parameter group"
  type        = string
}

variable "parameters" {
  description = "List of parameter settings for the parameter group"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = [
    { name = "ad hoc distributed queries", value = "1" }
  ]
}