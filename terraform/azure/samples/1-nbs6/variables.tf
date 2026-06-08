#### Prviate AGW ####
variable "agw_resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}


variable "agw_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "agw_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "agw_subnet_name" {
  description = "App Gateway Subnet"
  type        = string
}

variable "agw_key_vault_name" {
  description = "Key Vault Name"

  type = string
}

variable "agw_key_vault_cert_name" {
  description = "Key Vault Certificate Name"
  type        = string
}

variable "agw_key_vault_cert_rg" {
  description = "Key Vault Certificate Resource Group"
  type        = string
}

variable "agw_backend_host" {
  description = "URL Expected by NGINX Ingress"
  type        = string
}

variable "agw_aci_ip" {
  description = "ACI 3 IPs"
  type        = list(any)
}

variable "agw_private_ip" {
  description = "AGW Private IP Address"
  type        = string
}


#### SQLMI ####

variable "sqlmi_resource_prefix" {
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
  description = "Key Vault Name to Store SQLMI Credentials"
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

variable "sqlmi_restoring_from_database_name" {
  description = "SQL Managed Database to Restore From"
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

variable "sqlmi_timezone_id" {
  description = "The TimeZone ID that the SQL Managed Instance will be operating in"
  type        = string
}
