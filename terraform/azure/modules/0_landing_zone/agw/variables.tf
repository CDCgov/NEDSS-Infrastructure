variable "resource_prefix" {
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
  description = "Subnet to deploy App Gateway in"
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

variable "agw_key_vault_cert_secret_name" {
  description = "Key Vault Secret Name"
  type        = string
}

variable "agw_backend_host" {
  description = "URL Expected by NGINX Ingress"
  type        = string
}

variable "agw_aks_ip" {
  description = "AKS Internal Loadbalancer IP"
  type        = string
}