#### Used by multiple modules: ####

variable "vnet_name" {
  description = "Name of the VNet created by Layer 0"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "environment_name" {
  description = "The name of the NBS 7 environment"
  type        = string
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
}


## AGW Public

variable "agw_subnet_name" {
  description = "Subnet to deploy App Gateway in"
  type        = string
  default     = "public_gateways" # Must be a subnet in the 'subnets' variable in ../0-landing-zone/subnet.tf
}

variable "agw_key_vault_name" {
  description = "Existing Key Vault Name."
  type        = string
}

variable "agw_key_vault_cert_rg" {
  description = "Key Vault Certificate Resource Group"
  type        = string
}

variable "agw_key_vault_cert_name_public" {
  description = "Name of the Key Vault secret that stores the public certificate"
  type        = string
}

variable "agw_key_vault_cert_name_private" {
  description = "Name of the Key Vault secret that stores the private certificate"
  type        = string
}

variable "agw_backend_host" {
  description = "URL Expected by Traefik Ingress"
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

variable "agw_public_hostname" {
  description = "The public FQDN mapped to the Application Gateway public listener."
  type        = string
}

variable "agw_private_ip" {
  description = "The static private IP address assigned to the Application Gateway frontend configuration."
  type        = string
}

variable "agw_private_hostname" {
  description = "The private FQDN mapped to the Application Gateway private listener"
  type        = string
}

## AKS

variable "kubernetes_version_control_plane" { # Reference info: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#kubernetes_version-1
  type        = string
  description = "The Kubernetes version to use for the control plane of the K8s cluster in AKS"
  default     = "1.36"
}

# Reference info: https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions "Supported Kubernetes versions in Azure Kubernetes Service (AKS)"

variable "kubernetes_default_node_pool_orchestrator_version" { # Reference info: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#orchestrator_version-1
  type        = string
  description = "The Kubernetes version to use for the nodes/agents in the default node pool of the K8s cluster"
  default     = "1.36" # Must not be a newer version than what is specified by the 'kubernetes_version_control_plane' variable above, and must not be more than three minor versions behind 'kubernetes_version_control_plane'.
}

variable "aks_modern_subnet" {
  type    = list(any)
  default = ["aks"] # Must be a subnet in the 'subnets' variable in ../0-landing-zone/subnet.tf
}

variable "aks_rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "List of group ids with access to the AKS cluster control plane"
}

## Kafka

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

variable "kafka_vnet_rg" {
  type = string
}

variable "kafka_subnet_name" {
  type    = string
  default = "hdikafka" # Must be a subnet in the 'subnets' variable in ../0-landing-zone/subnet.tf
}

variable "kafka_infrastructure_encryption_enabled" {
  type    = bool
  default = true
}


## Observability
variable "observability_cluster_name" {
  type        = string
  description = "Name of AKS cluster for which monitoring will be set up"

}


## Private DNS Zone
variable "private_dns_virtual_network_name" {
  type        = list(string)
  description = "StringList of virtual network names to be associated as a virtual network link for the private dns zone."
}


## Storage Account

variable "storage_account_subnet_name" {
  type        = string
  description = "Name of subnet within virtual_network_name to be associated with storage account private endpoints."
  default     = "endpoint" # Must be a subnet in the 'subnets' variable in ../0-landing-zone/subnet.tf
}

variable "storage_account_virtual_network_name" {
  type        = string
  description = "Name of virtual network to be associated with storage account private endpoints."
}
