## AGW Public
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
  description = "Subnet to deploy App Gateway in"
  type        = string
}

variable "agw_key_vault_name" {
  description = "Existing Key Vault Name."
  type        = string
}

variable "agw_key_vault_cert_rg" {
  description = "Key Vault Certificate Resource Group"
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

variable "agw_aks_ip" {
  description = "AKS Internal Loadbalancer IP"
  type        = string
}

variable "agw_nsg_akamai_ips" {
  description = "List of Akamai IPs to allow inbound traffic on port 443"
  type        = list(string)
}

## AKS

variable "aks_modern_resource_group_name" {
  type        = string
  description = "This defines the modern resource group name"
}

variable "aks_k8_cluster_name" {
  type        = string
  description = "This defines the name for the k8 cluster"
}

variable "aks_k8_cluster_version" {
  type        = string
  description = "This defines the version of the k8 cluster"
}

variable "aks_modern_subnet" {
  type = list(any)
}

variable "aks_resource_prefix" {
  type        = string
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
}

variable "aks_rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "List of group ids with access to the AKS cluster control plane"
}

## Kafka

variable "kafka_location" {
  description = "Location for Azure resources"
  type        = string
}

variable "kafka_storage_account_name" {
  type = string
}

variable "kafka_sg_name" {
  type = string
}

variable "kafka_cluster_name" {
  type = string
}

variable "kafka_gtwy_username" {
  type = string
}

variable "kafka_gtwy_password" {
  type      = string
  sensitive = true
}

variable "kafka_username" {
  type = string
}

variable "kafka_password" {
  type      = string
  sensitive = true
}

variable "kafka_vnet_name" {
  type = string
}

variable "kafka_vnet_rg" {
  type = string
}

variable "kafka_subnet_name" {
  type = string
}

variable "kafka_infrastructure_encryption_enabled" {
  type    = bool
  default = true
}


## Observability

variable "observability_resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"

}

variable "observability_cluster_name" {
  type        = string
  description = "Name of AKS cluster for which monitoring will be set up"

}


## Private DNS Zone

variable "private_dns_resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"
}

variable "private_dns_virtual_network_name" {
  type        = list(string)
  description = "StringList of virtual network names to be associated as a virtual network link for the private dns zone."
}


## Storage Account

variable "storage_account_resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"

}

variable "storage_account_subnet_name" {
  type        = string
  description = "Name of subnet within virtual_network_name to be associated with storage account private endpoints."
}

variable "storage_account_virtual_network_name" {
  type        = string
  description = "Name of virtual network to be associated with storage account private endpoints."
}

