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

variable "vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}

variable "database_subnets" {
  description = "Subnet Ids to be used when creating RDS"
  type        = list(any)

  validation {
    condition = alltrue([
      for s in data.aws_subnet.selected :
      s.vpc_id == var.vpc_id
    ])
    error_message = "All subnet_ids must exist and belong to the specified vpc_id."
  }
}

variable "db_instance_type" {
  description = "Database instance type"
  type        = string
}

variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS isntance"
  type        = string
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = true
}

variable "ingress_security_group_id" {
  description = "Security group id of NBS6 instance to allow traffic into RDS"
  type        = string
  default     = null
}

variable "additional_ingress_cidr" {
  description = "CSV of CIDR blocks which will have access to RDS instance"
  type        = string
  default     = ""
}
