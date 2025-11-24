variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

/*
variable "k8_admin_username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "cdcnbsadmin"
}
*/

/*
#Server Principal Name for Data Source
variable "azuread_service_principal_display_name" {
  type        = string
  description = "Azure AD Service Principal Display Name"
}
*/

#K8 cluster variables
variable "modern_resource_group_name" {
  type        = string
  description = "This defines the modern resource group name"
}

variable "k8_cluster_name" {
  type        = string
  description = "This defines the name for the k8 cluster"
}

variable "k8_cluster_version" {
  type        = string
  description = "This defines the version of the k8 cluster"
}

variable "k8_cluster_location" {
  type        = string
  description = "This defines the default location for the k8 cluster"
  default     = "East US"
}

/*
variable "k8_dns_prefix" {
  type = string
  description = "This defines the k8 dns prefix"
}
*/


#k8 node pool variables

variable "default_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "systempool"
}

variable "node_pool_vm_size" {
  type        = string
  description = "This defines the node pool size"
  default     = "Standard_DS2_v2"
}

variable "node_pool_zones" {
  type        = list(any)
  description = "AZs for the default node pool nodes"
  default     = [1, 2, 3]
}


variable "node_pool_max_count" {
  type        = number
  description = "This defines the default node pool max count"
  default     = 5
}


variable "node_pool_min_count" {
  type        = number
  description = "This defines the default node pool min count"
  default     = 2
}

variable "node_pool_disk_size_gb" {
  type        = number
  description = "This defines the default node disk size"
  default     = 30
}

variable "node_pool_type" {
  type        = string
  description = "This defines the default node pool type"
  default     = "VirtualMachineScaleSets"
}


variable "node_pool_network_plugin" {
  type        = string
  description = "This defines the k8 network plugin"
  default     = "kubenet"
}


variable "node_pool_load_balancer_sku" {
  type        = string
  description = "This defines load balancer sku"
  default     = "standard"
}

variable "network_profile_pod_cidr" {
  type        = string
  description = "This defines the default value for pod CIDR"
  default     = "10.1.0.0/16"
}

variable "temporary_name_for_rotation" {
  type        = string
  description = "This defines the default value for temp name for node rotation"
  default     = "tempnode"

}

variable "identity_type" {
  type        = string
  description = "This defines the default value for identity type"
  default     = "UserAssigned"

}

/*
variable "service_principal_client_secret" {
  type = string
  description = "This defines service principal client secret"
}
*/

variable "user_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "userlnxpool"
}

variable "modern_subnet" {
  type = list(any)
}

variable "resource_prefix" {
  type        = string
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
}