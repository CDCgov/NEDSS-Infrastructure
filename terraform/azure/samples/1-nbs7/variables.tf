#### Used by multiple modules: ####

variable "vnet_name" {
  description = "Name of the VNet created by Layer 0"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_location" {
  type        = string
  description = "The Azure region"
  default     = "eastus"
}

variable "environment_name" {
  description = "The name of the NBS 7 environment"
  type        = string
}


################################################################################
# HDInsights Kafka
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/hdi-kafka/variables.tf
################################################################################

variable "kafka_enabled" {
  type        = bool
  description = "Enable the module"
  default     = true
}

variable "kafka_resource_prefix" {
  type    = string
  default = ""
}

variable "kafka_storage_account_name" {
  type = string
}

variable "kafka_account_tier" {
  type    = string
  default = "Standard"
}

variable "kafka_account_replication_type" {
  type    = string
  default = "LRS"
}

# variable "kafka_storage_container_name"{ 
#     type = string
# }

variable "kafka_container_access_type" {
  type    = string
  default = "private"
}

variable "kafka_sg_name" {
  type = string
}

variable "kafka_cluster_version" {
  type    = string
  default = "5.1"
}

variable "kafka_cluster_tier" {
  type    = string
  default = "Standard"
}

variable "kafka_component_version" {
  type    = string
  default = "3.2"
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

variable "kafka_head_vm_size" {
  type    = string
  default = "Standard_D2s_v7"
}

variable "kafka_worker_vm_size" {
  type    = string
  default = "Standard_D2s_v7"
}

variable "kafka_zookeeper_vm_size" {
  type    = string
  default = "Standard_D2s_v7"
}

variable "kafka_encryption_in_transit_enabled" {
  type    = bool
  default = true
}

variable "kafka_number_of_disks_per_node" {
  type    = number
  default = 1
}

variable "kafka_target_instance_count" {
  type    = number
  default = 3
}

variable "kafka_subnet_name" {
  type = string
}

variable "kafka_tls_min_version" {
  type    = string
  default = "1.2"
}

variable "kafka_destination_address_prefix" {
  type    = string
  default = "VirtualNetwork"
}

variable "kafka_tags" {
  type = map(string)
  default = {
    createdby = "Terraform"
  }
}

variable "kafka_infrastructure_encryption_enabled" {
  type    = bool
  default = true
}

variable "kafka_nat_gateway_enabled" {
  type        = bool
  description = "Enable NAT gateway to allow VM helath checks to reach the management api"
  default     = true
}

################################################################################
# Storage Account
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/storage-account/variables.tf
################################################################################

variable "storage_account_name" {
  type        = string
  description = "Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)"
  default     = "nbsstorageaccount"
}

variable "storage_account_account_kind" {
  type        = string
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"

}

variable "storage_account_account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  default     = "Standard"

}

variable "storage_account_create_dns_record" {
  type        = bool
  description = "Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint."
  default     = false
}

variable "storage_account_blob_private_ip_address" {
  type        = string
  description = "Private IP address to set for storage account file endpoint."
  default     = null
}

variable "storage_account_file_private_ip_address" {
  type        = string
  description = "Private IP address to set for storage account file endpoint."
  default     = null
}

# For definitions see https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
variable "storage_account_account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
  default     = "GRS"

}

variable "storage_account_subnet_name" {
  type        = string
  description = "Name of subnet within virtual_network_name to be associated with storage account private endpoints."
}

variable "storage_account_infrastructure_encryption_enabled" {
  type        = bool
  description = "Is infrastructure encryption enabled?"
  default     = true
}

# Network
variable "storage_account_public_network_access_enabled" {
  type        = bool
  description = "Whether the public network access is enabled?"
  default     = false
}

variable "storage_account_dns_zone_id_blob" {
  type        = string
  description = "Zone id of DNS to which record will be added for blob storage.(create_dns_record must be true)"
  default     = ""
}

variable "storage_account_dns_zone_name_blob" {
  type        = string
  description = "Name of DNS zone to which record will be added for blob storage. (create_dns_record must be true)"
  default     = ""
}

variable "storage_account_dns_zone_id_file" {
  type        = string
  description = "Zone id of DNS to which record will be added for file storage. (create_dns_record must be true)"
  default     = ""
}

variable "storage_account_dns_zone_name_file" {
  type        = string
  description = "Name of DNS zone to which record will be added for file storage. (create_dns_record must be true)"
  default     = ""
}

# Data retention
variable "storage_account_blob_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft deleted blobs. Default 7 days."
  default     = 7
}

variable "storage_account_blob_container_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft delete containers. Default 7 days."
  default     = 7
}

# ------------------------------------------------------------------------------
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/storage-dns-zone/variables.tf
# ------------------------------------------------------------------------------
variable "storage_dns_zone_virtual_network_name" {
  type        = list(string)
  description = "List of virtual network names to be associated as a virtual network link for the private dns zone."
  default     = []
}

# ------------------------------------------------------------------------------
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/observability/variables.tf
# ------------------------------------------------------------------------------
variable "observability_resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = ""
}

variable "observability_update_admin_role_assignment" {
  type        = bool
  description = "Allow observability to give deployment role admin permissions to the grafana dashboard"
  default     = true
}

variable "observability_grafana_major_version" {
  type        = string
  description = "Major version number for Grafana"
  default     = "12"
}

# ------------------------------------------------------------------------------
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/aks/variables.tf
# ------------------------------------------------------------------------------
variable "aks_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "aks_msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}


# K8s cluster variables:

variable "aks_agents_size" {
  type        = string
  default     = "Standard_D2s_v7"
  description = "The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created."
}

variable "aks_k8_cluster_version" {
  type        = string
  description = "Which Kubernetes release to use for the K8s cluster"
  default     = "1.35"
}

# K8s node pool variables:

variable "aks_default_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "systempool"
}

variable "aks_k8_orchestrator_version" {
  type        = string
  description = "Which Kubernetes release to use for the nodes/agents in the default node pool of the K8s cluster"
  default     = "1.35"
}

variable "aks_node_pool_vm_size" {
  type        = string
  description = "This defines the node pool size"
  default     = "Standard_D2s_v7"
}

variable "aks_node_pool_zones" {
  type        = list(any)
  description = "AZs for the default node pool nodes"
  default     = [1, 2, 3]
}


variable "aks_node_pool_max_count" {
  type        = number
  description = "This defines the default node pool max count"
  default     = 5
}


variable "aks_node_pool_min_count" {
  type        = number
  description = "This defines the default node pool min count"
  default     = 2
}

variable "aks_node_pool_disk_size_gb" {
  type        = number
  description = "This defines the default node disk size"
  default     = 30
}

variable "aks_node_pool_type" {
  type        = string
  description = "This defines the default node pool type"
  default     = "VirtualMachineScaleSets"
}

variable "aks_node_pool_network_plugin" {
  type        = string
  description = "This defines the k8 network plugin"
  default     = "kubenet"
}

variable "aks_node_pool_load_balancer_sku" {
  type        = string
  description = "This defines load balancer sku"
  default     = "standard"
}

variable "aks_network_profile_pod_cidr" {
  type        = string
  description = "This defines the default value for pod CIDR"
  default     = "10.244.0.0/16"
}

variable "aks_net_profile_service_cidr" {
  type        = string
  description = "This defines the default value for the service CIDR"
  default     = "10.96.0.0/16"
}

variable "aks_net_profile_dns_service_ip" {
  type        = string
  description = "This defines the default value for the dns service IP address"
  default     = "10.96.0.10"
}

variable "aks_temporary_name_for_rotation" {
  type        = string
  description = "This defines the default value for temp name for node rotation"
  default     = "tempnode"
}

variable "aks_identity_type" {
  type        = string
  description = "This defines the default value for identity type"
  default     = "UserAssigned"
}

variable "aks_user_node_pool_name" {
  type        = string
  description = "This defines the default node pool names"
  default     = "userlnxpool"
}

variable "aks_modern_subnet" {
  type    = list(any)
  default = []
}

variable "aks_resource_prefix" {
  type        = string
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  default     = ""
}

variable "aks_vnet_name" {
  type        = string
  description = "Name of the existing vnet"
  default     = "csels-nbs-dev-low-modern-vnet"
}

variable "aks_subnet_name_aks" {
  type        = string
  description = "Name of the aks subnet"
  default     = "csels-nbs-dev-low-modern-vnet-sn"
}

variable "aks_rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "List of group ids with access to the AKS cluster control plane"
}

variable "aks_create_modern_subnet" {
  type        = bool
  description = "Creates a new subnet for the AKS cluster"
  default     = false
}

variable "aks_existing_modern_subnet_name" {
  type        = string
  description = "Name of the existing aks subnet"
  default     = ""
}

variable "aks_auto_scaling_enabled" {
  type        = bool
  default     = true
  description = "Enable node pool autoscaling"
}

variable "aks_os_sku" {
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

variable "aks_enable_cert_manager" {
  description = "Create cert-manager helm release and associated Managed Identity"
  type        = bool
  default     = true
}

variable "aks_dns_zone_id" {
  description = "Id for the associated DNS zone"
  type        = string
  default     = ""
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


# ------------------------------------------------------------------------------
# Source: NEDSS-Infrastructure/terraform/azure/modules/1-nbs7/agw-public/variables.tf
# ------------------------------------------------------------------------------
variable "agw_public_enabled" {
  description = <<EOT
  Whether to have Terraform provision the resources from this module 
  in your Azure subscription
  EOT
  type        = bool
  default     = true
}

variable "agw_vnet_name" {
  description = <<EOT
  The name of the Azure Virtual Network (VNet) containing the 
  Application Gateway subnet.
  EOT
  type        = string
}

variable "agw_subnet_name" {
  description = "Subnet for Application Gateway deployment"
  type        = string
}

variable "agw_key_vault_cert_rg" {
  description = "Key Vault Certificate Resource Group"
  type        = string
}

variable "agw_key_vault_cert_name_public" {
  description = <<EOT
  Name of the Key Vault secret that stores the public certificate
  EOT
  type        = string
}

variable "agw_key_vault_cert_name_private" {
  description = <<EOT
  Name of the Key Vault secret that stores the private certificate
  EOT
  type        = string
  default     = null
}

variable "agw_app_backend_host" {
  description = <<-EOT
  The target host header or FQDN expected by the Traefik ingress 
  controller for routing.
EOT
  type        = string
}

variable "agw_data_backend_host" {
  description = <<-EOT
  The target host header or FQDN expected by the Traefik ingress 
  controller for routing.
EOT
  type        = string
}

variable "agw_aks_ip" {
  description = <<-EOT
  The private IP address of the Azure Kubernetes Service (AKS) internal 
  load balancer backend.
  EOT
  type        = string
}

variable "agw_nsg_akamai_ips" {
  description = <<EOT
    List of Akamai IPs to allow inbound traffic on port 443. Supports
    IPv4 addresses and CIDR blocks.
  EOT
  type        = list(string)
  default     = []
}

variable "agw_role_based_kv" {
  description = <<-EOT
  Specifies whether the Key Vault uses Azure Role-Based Access Control 
  (RBAC) instead of access policies.
EOT
  type        = bool
  default     = false
}

variable "agw_role_definition_name" {
  description = <<EOT
  The Azure RBAC role definition name (e.g., 'Key Vault Secrets User') 
  assigned to the Application Gateway identity for secret access.
  EOT
  type        = string
  default     = ""
}

variable "agw_enable_dual_gateway" {
  description = <<EOT
  Controls whether to share a single Application Gateway for NBS 7 
  and NBS 6 traffic. When set to false, a separate gateway is required for
  NBS 6
  EOT
  type        = bool
  default     = true
}

variable "agw_app_public_hostname" {
  description = <<EOT
  The public FQDN mapped to the Application Gateway public listener.
  EOT
  type        = string
}

variable "agw_data_public_hostname" {
  description = <<EOT
  The public FQDN mapped to the Application Gateway public listener.
  EOT
  type        = string
}

variable "agw_private_ip" {
  description = <<EOT
    The static private IP address assigned to the Application Gateway
    frontend configuration.
  EOT
  type        = string
  default     = null
}

variable "agw_private_backend_host" {
  description = <<EOT
    The target backend host header/FQDN used for internal routing by
    the Application Gateway.
  EOT
  type        = string
  default     = null
}

variable "agw_nbs_ip_private" {
  description = <<-EOT
    Private IP address for the internal NBS 6 backend service target
    pool.
  EOT
  type        = string
  default     = null
}

variable "agw_private_hostname" {
  description = <<EOT
  The private FQDN mapped to the Application Gateway private listener
  EOT
  type        = string
  default     = null
}
