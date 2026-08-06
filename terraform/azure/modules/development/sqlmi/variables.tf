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
  sensitive   = true
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

variable "sqlmi_storage_account_type" {
  description = "Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created. Possible values are GRS, GZRS, LRS, and ZRS. Defaults to GRS"
  type        = string
  default     = "ZRS"
}

variable "sqlmi_zone_redundant_enabled" {
  description = "Specifies whether or not the SQL Managed Instance is zone redundant. Defaults to false."
  type        = string
  default     = true
}

variable "sqlmi_timezone_id" {
  description = "The TimeZone ID that the SQL Managed Instance will be operating in"
  type        = string
}






