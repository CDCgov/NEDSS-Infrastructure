#ACR Module Variables
variable "container_registry_name" {
  type = string
  description = "This defines the container registry name"
}

variable "container_registry_sku" {
  type = string
  description = "This defines the container registry sku"
}

variable "service_principal_name" {
  type = string
  description = "This defines the AAD service principal name"
}

variable "container_registry_resource_group_name" {
  type = string
  description = "This defines the container registry resource group name"
}


# Service Principal Details
variable "subscription_id" {
  type = string
  description = "This defines the server principal subscription ID"
}
variable "tenant_id" {
  type = string
  description = "This defines the server principal tenant ID"
}
variable "client_id" {
  type = string
  description = "This defines the server principal client ID"
}
variable "client_secret" {
  type = string
  description = "This defines the server principal client secret"
}



/*

Backend variables not used
variable "backend_resource_group_name" {
  type = string
  description = "terraform-storage-rg"
}
variable "backend_storage_account_name" {
  type = string
  description = "This defines the TF state backend storage account name"
}
variable "backend_container_name" {
  type = string
  description = "This defines the TF state backend container name"
}
variable "backend_key" {
  type = string
  description = "This defines the TF state backend key"
}

*/

/*
variable "k8_admin_username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "cdcnbsadmin"
}

variable "azuread_service_principal_display_name" {
  type        = string
  description = "Azure AD Service Principal Display Name"
}
*/

variable "modern_resource_group_name" {
  type = string
  description = "This defines the modern resource group name"
}

variable "k8_cluster_name" {
  type = string
  description = "This defines the name for the k8 cluster"
}

variable "k8_cluster_version" {
  type = string
  description = "This defines the version of the k8 cluster"
}

/*
variable "k8_dns_prefix" {
  type = string
  description = "This defines the k8 dns prefix"
}
*/
/*
variable "service_principal_client_secret" {
  type = string
  description = "This defines service principal client secret"
}
*/
variable "modern_subnet"{
  type= list(any)
}

variable "resource_prefix"{
  type = string
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
}