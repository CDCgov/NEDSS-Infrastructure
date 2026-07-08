module "aks_nbs7" {
  source = "../../modules/2-nbs7/aks"

  k8_cluster_version              = var.kubernetes_version_control_plane
  k8_orchestrator_version         = var.kubernetes_default_node_pool_orchestrator_version
  modern_resource_group_name      = var.vnet_resource_group_name
  modern_subnet                   = var.aks_modern_subnet
  rbac_aad_admin_group_object_ids = var.aks_rbac_aad_admin_group_object_ids
  resource_prefix                 = var.environment_name
}
