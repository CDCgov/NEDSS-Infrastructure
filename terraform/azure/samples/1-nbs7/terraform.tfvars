# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

################################################################################

# The following variables must be set to the same values that you gave these variables in ../0-landing-zone/terraform.tfvars

# The name of the VNet
vnet_name = "<your_environment_name>-nbs7"

# The name of the Resource Group
vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"

################################################################################
# Application Gateway
################################################################################

environment_name = "<your_environment_name>"

# These existing certificates must already be created in the Key vault that was provisioned by Layer 0:
agw_key_vault_cert_name_public  = "az-<your_STLT_name>nbs-wildcard-cert-secret"
agw_key_vault_cert_name_private = "az-<your_STLT_name>nbs-wildcard-cert-private"

agw_app_public_hostname  = "app-<your_environment_name>.az.<your_STLT_name>nbs.com"
agw_data_public_hostname = "<>"
agw_app_backend_host     = "<>"
agw_data_backend_host    = "<>"
agw_private_ip           = "<00.0.00.00>"
agw_private_hostname     = "classic-<your_environment_name>.az.<your_STLT_name>nbs.com"

# The private IP address of the Azure Kubernetes Service (AKS) internal 
# load balancer backend.
agw_aks_ip = "<>"

# Key Vault Certificate Resource Group
agw_key_vault_cert_rg = "<>"

# Name of Existing Key Vault containing public/private 
#   certificates stored as secrets
agw_key_vault_name = "<>"

# Private IP address for the internal NBS 6 backend service target
# pool.
# agw_nbs_ip_private =

# The target backend host header/FQDN used for internal routing by
#     the Application Gateway.
# agw_private_backend_host =

# The private FQDN mapped to the Application Gateway private listener
# agw_private_hostname =

# The static private IP address assigned to the Application Gateway
#     frontend configuration.
# agw_private_ip =

# The Azure RBAC role definition name (e.g., 'Key Vault Secrets User') 
#   assigned to the Application Gateway identity for secret access.
# agw_role_definition_name =

# Subnet for Application Gateway deployment
agw_subnet_name = "<>"

# The name of the Azure Virtual Network (VNet) containing the 
#   Application Gateway subnet.
agw_vnet_name = "<>"

# Controls whether to share a single Application Gateway for NBS 7 
#   and NBS 6 traffic. When set to false, a separate gateway is required for
#   NBS 6
# agw_public_enable_dual_gateway =

# Whether to have Terraform provision the resources from this module 
#   in your Azure subscription
# agw_public_enabled =

# List of Akamai IPs to allow inbound traffic on port 443. Supports
#     IPv4 addresses and CIDR blocks.
# agw_public_nsg_akamai_ips =

# Specifies whether the Key Vault uses Azure Role-Based Access Control 
# (RBAC) instead of access policies.
# agw_public_role_based_kv =


################################################################################

# Uncomment these variables if you wish to use a different version than the default value in ./variables.tf for these variables:

# The control plane version of the Kubernetes cluster in AKS:
#kubernetes_version_control_plane = "<your_desired_Kubernetes_minor_version>"
# The orchestrator_version of the cluster's default_node_pool:
#kubernetes_default_node_pool_orchestrator_version = "<your_desired_Kubernetes_minor_version>"

################################################################################

################################################################################
# Azure Kubernetes Service (AKS)
################################################################################

# Enable node pool autoscaling
# aks_auto_scaling_enabled =

# Creates a new subnet for the AKS cluster
# aks_create_modern_subnet =

# This defines the default node pool names
# aks_default_node_pool_name =

# Id for the associated DNS zone
# aks_dns_zone_id =

# Create cert-manager helm release and associated Managed Identity
# aks_enable_cert_manager =

# Name of the existing aks subnet
# aks_existing_modern_subnet_name =

# This defines the default value for identity type
# aks_identity_type =

# aks_agents_size = 

# Which Kubernetes release to use for the K8s cluster
aks_k8_cluster_version = "<>"

# Which Kubernetes release to use for the nodes/agents in the default node pool of the K8s cluster
aks_k8_orchestrator_version = "<>"


# aks_modern_subnet =

# The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method.
# aks_msi_id =

# This defines the default value for the dns service IP address
# aks_net_profile_dns_service_ip =

# This defines the default value for the service CIDR
# aks_net_profile_service_cidr =

# This defines the default value for pod CIDR
# aks_network_profile_pod_cidr =

# The initial quantity of nodes for the node pool.
# aks_node_count =

# This defines the default node disk size
# aks_node_pool_disk_size_gb =

# This defines load balancer sku
# aks_node_pool_load_balancer_sku =

# This defines the default node pool max count
# aks_node_pool_max_count =

# This defines the default node pool min count
# aks_node_pool_min_count =

# This defines the k8 network plugin
# aks_node_pool_network_plugin =

# This defines the default node pool type
# aks_node_pool_type =

# This defines the node pool size
# aks_node_pool_vm_size =

# AZs for the default node pool nodes
# aks_node_pool_zones =

# Specifies the OS SKU used by the agent pool. Possible values include: 
# `Ubuntu`, `Ubuntu2204`,`Ubuntu2404`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. 
# If not specified, the default is `Ubuntu` if OSType=Linux or 
# `Windows2019` if OSType=Windows. And the default Windows OSSKU 
# will be changed to `Windows2022` after Windows2019 is deprecated. 
# Changing this forces a new resource to be created.
# aks_os_sku =

# List of group ids with access to the AKS cluster control plane
aks_rbac_aad_admin_group_object_ids = []

# Name to be used on all the resources as identifier. e.g. Project name, Application name
aks_resource_prefix = "<>"

# Name of the aks subnet
# aks_subnet_name_aks =

# This defines the default value for temp name for node rotation
# aks_temporary_name_for_rotation =

# This defines the default node pool names
# aks_user_node_pool_name =

# Name of the existing vnet
# aks_vnet_name =

# Create resources for DataCompare service
# create_datacompare_resources=

# Create resources for OTEL Collector log export
# create_otel_collector_resources =

################################################################################
# HDInsights Kafka
################################################################################

kafka_gtwy_password        = "<>"
kafka_gtwy_username        = "<>"
kafka_cluster_name         = "<>"
kafka_subnet_name          = "<>"
kafka_password             = "<>"
kafka_sg_name              = "<>"
kafka_storage_account_name = "<>"
kafka_username             = "<>"
kafka_vnet_name            = "<>"
kafka_vnet_rg              = "<>"

# kafka_account_replication_type =

# kafka_account_tier =

# kafka_cluster_tier =

# kafka_cluster_version =

# kafka_component_version =

# kafka_container_access_type =

# kafka_destination_address_prefix =

# Enable the module
# kafka_enabled =

# kafka_encryption_in_transit_enabled =

# kafka_head_vm_size =

# kafka_infrastructure_encryption_enabled =

# Enable NAT gateway to allow VM helath checks to reach the management api
# kafka_nat_gateway_enabled =

# kafka_number_of_disks_per_node =

# kafka_resource_prefix =

# kafka_tags =

# kafka_target_instance_count =

# kafka_tls_min_version =

# kafka_worker_vm_size =

# kafka_zookeeper_vm_size =


################################################################################
# Observability
################################################################################

# Major version number for Grafana
# observability_grafana_major_version =

# Prefix for resource names
# observability_resource_prefix =

# Allow observability to give deployment role admin permissions to the grafana dashboard
# observability_update_admin_role_assignment =



################################################################################
# Storage Account
################################################################################

# Name of subnet within virtual_network_name to be associated with storage account private endpoints.
storage_account_subnet_name = "<>"

# Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
# storage_account_account_kind =

# Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa.
# storage_account_account_replication_type =

# Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created.
# storage_account_account_tier =

# Number of days to retain soft delete containers. Default 7 days.
# storage_account_blob_container_delete_retention_days =

# Number of days to retain soft deleted blobs. Default 7 days.
# storage_account_blob_delete_retention_days =

# Private IP address to set for storage account file endpoint. (leave null to auto assign)
# storage_account_blob_private_ip_address =

# Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint.
# storage_account_create_dns_record =

# Zone id of DNS to which record will be added for blob storage.(create_dns_record must be true)
# storage_account_dns_zone_id_blob =

# Zone id of DNS to which record will be added for file storage. (create_dns_record must be true)
# storage_account_dns_zone_id_file =

# Name of DNS zone to which record will be added for blob storage. (create_dns_record must be true)
# storage_account_dns_zone_name_blob =

# Name of DNS zone to which record will be added for file storage. (create_dns_record must be true)
# storage_account_dns_zone_name_file =

# Private IP address to set for storage account file endpoint. (leave null to auto assign)
# storage_account_file_private_ip_address =

# Is infrastructure encryption enabled?
# storage_account_infrastructure_encryption_enabled =

# Whether the public network access is enabled?
# storage_account_public_network_access_enabled =

# Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)
# storage_account_name =


################################################################################
# Storage Account DNS Zone
################################################################################

# StringList of virtual network names to be associated as a virtual network link for the private dns zone.
# storage_dns_zone_virtual_network_name =
