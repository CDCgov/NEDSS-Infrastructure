variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
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


variable "modern_resource_group_name" {
  type        = string
  description = "This defines the modern resource group name"
}


# K8s cluster variables:

variable "k8_cluster_version" {
  type        = string
  description = "This defines the version of the k8 cluster"
}

variable "k8_cluster_location" {
  type        = string
  description = "This defines the default location for the k8 cluster"
  default     = "East US"
}


# K8s node pool variables:

variable "default_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "systempool"
}

variable "node_pool_vm_size" {
  type        = string
  description = "This defines the node pool size"
  default     = "Standard_DS2_v4"
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
  default     = "10.244.0.0/16"
}

variable "net_profile_service_cidr" {
  type        = string
  description = "This defines the default value for the service CIDR"
  default     = "10.96.0.0/16"
}

variable "net_profile_dns_service_ip" {
  type        = string
  description = "This defines the default value for the dns service IP address"
  default     = "10.96.0.10"
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

variable "user_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "userlnxpool"
}

variable "modern_subnet" {
  type    = list(any)
  default = []
}

variable "resource_prefix" {
  type        = string
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
}

variable "vnet_name" {
  type        = string
  description = "Name of the existing vnet"
  default     = "csels-nbs-dev-low-modern-vnet"
}

variable "subnet_name_aks" {
  type        = string
  description = "Name of the aks subnet"
  default     = "csels-nbs-dev-low-modern-vnet-sn"
}

variable "rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "List of group ids with access to the AKS cluster control plane"
}

variable "create_modern_subnet" {
  type        = bool
  description = "Creates a new subnet for the AKS cluster"
  default     = false
}

variable "existing_modern_subnet_name" {
  type        = string
  description = "Name of the existing aks subnet"
  default     = ""

  validation {
    condition     = !var.create_modern_subnet || var.existing_modern_subnet_name != ""
    error_message = "existing_modern_subnet_name must be provided if create_modern_subnet is set to true"
  }
}

variable "os_sku" {
  type        = string
  description = <<-EOT
  Specifies the OS SKU used by the agent pool. Possible values include: 
  `Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. 
  If not specified, the default is `Ubuntu` if OSType=Linux or 
  `Windows2019` if OSType=Windows. And the default Windows OSSKU 
  will be changed to `Windows2022` after Windows2019 is deprecated. 
  Changing this forces a new resource to be created.
EOT
  default     = "Ubuntu2204"
}
