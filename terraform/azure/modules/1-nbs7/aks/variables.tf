variable "resource_group_location" {
  description = "Location of the resource group."
  type        = string
  default     = "eastus"
}

variable "node_count" {
  description = "The initial quantity of nodes for the node pool."
  type        = number
  default     = 3
}

variable "msi_id" {
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  type        = string
  default     = null
}

variable "modern_resource_group_name" {
  description = "This defines the modern resource group name"
  type        = string
}


# K8s cluster variables:

variable "k8_cluster_version" {
  description = "Which Kubernetes release to use for the K8s cluster"
  type        = string
}

variable "k8_cluster_location" {
  description = "This defines the default location for the k8 cluster"
  type        = string
  default     = "East US"
}


# K8s node pool variables:

variable "default_node_pool_name" {
  description = "This defines the default node pool names"
  type        = string
  default     = "systempool"
}

variable "k8_orchestrator_version" {
  description = "Which Kubernetes release to use for the nodes/agents in the default node pool of the K8s cluster"
  type        = string
}

variable "agents_size" {
  description = "The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_pool_vm_size" {
  description = "This defines the node pool size"
  type        = string
  default     = "Standard_DS2_v4"
}

variable "node_pool_zones" {
  description = "AZs for the default node pool nodes"
  type        = list(any)
  default     = [1, 2, 3]
}

variable "node_pool_max_count" {
  description = "This defines the default node pool max count"
  type        = number
  default     = 5
}

variable "node_pool_min_count" {
  description = "This defines the default node pool min count"
  type        = number
  default     = 2
}

variable "node_pool_disk_size_gb" {
  description = "This defines the default node disk size"
  type        = number
  default     = 30
}

variable "node_pool_type" {
  description = "This defines the default node pool type"
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "node_pool_network_plugin" {
  description = "This defines the k8 network plugin"
  type        = string
  default     = "kubenet"
}

variable "node_pool_load_balancer_sku" {
  description = "This defines load balancer sku"
  type        = string
  default     = "standard"
}

variable "network_profile_pod_cidr" {
  description = "This defines the default value for pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "net_profile_service_cidr" {
  description = "This defines the default value for the service CIDR"
  type        = string
  default     = "10.96.0.0/16"
}

variable "net_profile_dns_service_ip" {
  description = "This defines the default value for the dns service IP address"
  type        = string
  default     = "10.96.0.10"
}

variable "temporary_name_for_rotation" {
  description = "This defines the default value for temp name for node rotation"
  type        = string
  default     = "tempnode"
}

variable "identity_type" {
  description = "This defines the default value for identity type"
  type        = string
  default     = "UserAssigned"
}

variable "user_node_pool_name" {
  description = "This defines the default node pool names"
  type        = string
  default     = "userlnxpool"
}

variable "modern_subnet" {
  type    = list(any)
  default = []
}

variable "resource_prefix" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing vnet"
  type        = string
  default     = "csels-nbs-dev-low-modern-vnet"
}

variable "subnet_name_aks" {
  description = "Name of the aks subnet"
  type        = string
  default     = "csels-nbs-dev-low-modern-vnet-sn"
}

variable "rbac_aad_admin_group_object_ids" {
  description = "List of group ids with access to the AKS cluster control plane"
  type        = list(string)
}

variable "create_modern_subnet" {
  description = "Creates a new subnet for the AKS cluster"
  type        = bool
  default     = false
}

variable "existing_modern_subnet_name" {
  description = "Name of the existing aks subnet"
  type        = string
  default     = ""

  validation {
    condition     = !var.create_modern_subnet || var.existing_modern_subnet_name != ""
    error_message = "existing_modern_subnet_name must be provided if create_modern_subnet is set to true"
  }
}

variable "auto_scaling_enabled" {
  description = "Enable node pool autoscaling"
  type        = bool
  default     = true
}

variable "os_sku" {
  description = <<-EOT
  Specifies the OS SKU used by the agent pool. Possible values include: 
  `Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. 
  If not specified, the default is `Ubuntu` if OSType=Linux or 
  `Windows2019` if OSType=Windows. And the default Windows OSSKU 
  will be changed to `Windows2022` after Windows2019 is deprecated. 
  Changing this forces a new resource to be created.
EOT
  type        = string
  default     = "Ubuntu2204"
}

variable "enable_cert_manager" {
  description = "Create cert-manager helm release and associated Managed Identity"
  type        = bool
  default     = true
}

variable "dns_zone_id" {
  description = "Id for the associated DNS zone"
  type        = string
  default     = ""

  validation {
    condition     = !var.enable_cert_manager || var.dns_zone_id != ""
    error_message = "A valid dns_zone_id must be provided when enable_cert_manager is true."
  }
}

variable "datacompare_namespace_and_service" {
  description = "List of Kubernetes namespace and services to be included in the datacompare federated credential"
  type        = map(any)
  default = {
    "api" = {
      "namespace" = "default"
      "service"   = "data-compare-api-service"
    }
    "processor" = {
      "namespace" = "default"
      "service"   = "data-compare-processor-service"
    }
  }
}

variable "datacompare_blob_container_name" {
  description = "Name of blob container to be used for datacompare role."
  type        = string
  default     = ""
}

variable "otel_collector_namespace_and_service" {
  description = "List of Kubernetes namespace and service for the OTEL Collector federated credential"
  type        = map(any)
  default = {
    "collector" = {
      "namespace" = "observability"
      "service"   = "splunk-otel-collector"
    }
  }
}

variable "otel_collector_blob_container_name" {
  description = "Name of blob container to be used for OTEL Collector log storage."
  type        = string
  default     = ""
}


variable "storage_account_name" {
  description = "Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)"
  type        = string
  default     = "nbsstorageaccount"
}

variable "create_datacompare_resources" {
  description = "Create resources for DataCompare service?"
  type        = bool
  default     = false
}

variable "create_otel_collector_resources" {
  description = "Create resources for OTEL Collector log export?"
  type        = bool
  default     = false
}
