variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

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

variable "aci_github_release_tag" {
  description = "Create URL and download Release Package from Release Artifacts. Default is always latest even if empty"
  type        = string
  default     = "latest"
}

variable "aci_nbs6_repository" {
  description = "NBS6 Docker Repository"
  type        = string
}

variable "aci_use_private_acr" {
  description = "Use private ACR? NOTE: If deploying in CDC Azure EXT, ACR needs to be created by Cloud Team"
  type        = string
  default     = false
}

variable "aci_private_acr_resource_group_name" {
  description = "The name of the Private ACR resource group. This can be different then ACI deployment RG"
  type        = string
  default     = "N/A"
}

variable "aci_private_acr_server_url" {
  description = "Private ACR Server URL. If deploying in CDC Azure EXT, this needs to be created by Cloud Team"
  type        = string
  default     = "N/A"
}

variable "aci_user_assigned_identity_name" {
  description = "User Assigned Idenitity Name. Allows ACI to pull image from private registry. If deploying in CDC Azure EXT, this needs to be created by Cloud Team"
  type        = string
  default     = "N/A"
}