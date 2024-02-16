variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "sqlmi_subnet_name" {
  description = "Subnet to deploy Azure SQl Managed Instance in"
  type        = string
}


variable "sqlmi_username" {
  description = "SQL Admin Username"
  type        = string
  sensitive = true
}

variable "sqlmi_password" {
  description = "SQL Admin Password"
  type        = string
  sensitive = true
}

variable "restoring_from_database_name" {
  description = "SQL Managed Database to Restore From"
  type        = string
}

variable "restore_point_in_time" {
  description = "Restore Point in Time"
  type        = string
}