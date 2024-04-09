variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}


#### ACI ####
variable "aci_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "aci_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "aci_subnet_name" {
  description = "Subnet to deploy ACI in. ACI Subnet should be the smallest CIDR Block"
  type        = string
}

variable "aci_cpu" {
  description = "CPU Allocation for NBS6 ACI"
  type        = string
}

variable "aci_memory" {
  description = "CPU Allocation for NBS6 ACI"
  type        = string
}

variable "aci_sql_database_endpoint" {
  description = "SQL Database endpoint"
  type        = string
}

variable "aci_github_release_tag" {
  description = "Create URL and download Release Package from Release Artifacts. Default is always latest even if empty"
  type        = string
  default      = "latest"
}

variable "aci_quay_nbs6_repository" {
  description = "Quay.io NBS6 Repository"
  type        = string
}


#### Prviate AGW ####

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
  type        = string
}

variable "agw_key_vault_cert_name" {
  description = "Key Vault Certificate Name"
  type        = string
}

variable "agw_backend_host" {
  description = "URL Expected by NGINX Ingress"
  type        = string
}

variable "agw_aci_ip" {
  description = "ACI 3 IPs"
  type        = list
}

variable "agw_private_ip" {
  description = "AGW Private IP Address"
  type        = string
}


#### SQLMI ####

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