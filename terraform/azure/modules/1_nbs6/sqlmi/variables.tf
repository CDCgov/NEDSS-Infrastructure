variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "sqlmi_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sqlmi_vnet_name" {
  description = "Name of vNet"
  type        = string
}

# Azure SQL Managed Instance 
variable "sqlmi_subnet_name" {
  description = "Subnet to deploy Azure SQl Managed Instance in"
  type        = string
}

variable "sqlmi_key_vault" {
  description = "KeyVault Name to Store SQLMI Credentials. KeyVault Should be Manually Created"
  type        = string
  sensitive = true
}

variable "sqlmi_vcore" {
  description = "SQL Virtual Cores"
  type        = string
}

variable "sqlmi_storage" {
  description = "SQL Storage"
  type        = string
}

variable "sqlmi_sku_name" {
  description = "SKU Name"
  type        = string
}

variable "sqlmi_restoring_from_database_name" {
  description = "SQL Managed Database Name to Restore From"
  type        = string
}

variable "sqlmi_restoring_from_database_rg" {
  description = "SQL Managed Database to Restore From Resource Group"
  type        = string  
}

variable "sqlmi_restore_point_in_time" {
  description = "Restore Point in Time"
  type        = string
}