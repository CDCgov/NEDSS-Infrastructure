module "aks_nbs7" {
  source = "../../modules/1-nbs7/aks"

  auto_scaling_enabled        = var.aks_auto_scaling_enabled
  create_modern_subnet        = var.aks_create_modern_subnet
  default_node_pool_name      = var.aks_default_node_pool_name
  dns_zone_id                 = var.aks_dns_zone_id
  enable_cert_manager         = var.aks_enable_cert_manager
  existing_modern_subnet_name = var.aks_existing_modern_subnet_name
  identity_type               = var.aks_identity_type
  k8_cluster_location         = var.vnet_location
  k8_cluster_version          = var.aks_k8_cluster_version
  k8_orchestrator_version     = var.aks_k8_orchestrator_version
  modern_resource_group_name  = var.vnet_resource_group_name
  modern_subnet               = var.aks_modern_subnet
  msi_id                      = var.aks_msi_id
  net_profile_dns_service_ip  = var.aks_net_profile_dns_service_ip
  net_profile_service_cidr    = var.aks_net_profile_service_cidr
  network_profile_pod_cidr    = var.aks_network_profile_pod_cidr

  # Node Pools
  node_count                  = var.aks_node_count
  node_pool_disk_size_gb      = var.aks_node_pool_disk_size_gb
  node_pool_load_balancer_sku = var.aks_node_pool_load_balancer_sku
  node_pool_max_count         = var.aks_node_pool_max_count
  node_pool_min_count         = var.aks_node_pool_min_count
  node_pool_network_plugin    = var.aks_node_pool_network_plugin
  node_pool_type              = var.aks_node_pool_type
  node_pool_vm_size           = var.aks_node_pool_vm_size
  node_pool_zones             = var.aks_node_pool_zones
  os_sku                      = var.aks_os_sku

  rbac_aad_admin_group_object_ids = var.aks_rbac_aad_admin_group_object_ids
  resource_group_location         = var.vnet_location
  resource_prefix                 = var.aks_resource_prefix
  subnet_name_aks                 = var.aks_subnet_name_aks
  temporary_name_for_rotation     = var.aks_temporary_name_for_rotation
  user_node_pool_name             = var.aks_user_node_pool_name
  vnet_name                       = var.vnet_name

}
