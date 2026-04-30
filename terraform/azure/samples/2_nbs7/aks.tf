module "aks_nbs7" {
  source = "../../modules/2_nbs7/aks"

  k8_cluster_name                 = var.aks_k8_cluster_name
  k8_cluster_version              = var.aks_k8_cluster_version
  modern_resource_group_name      = var.aks_modern_resource_group_name
  modern_subnet                   = var.aks_modern_subnet
  rbac_aad_admin_group_object_ids = var.aks_rbac_aad_admin_group_object_ids
  resource_prefix                 = var.aks_resource_prefix
}
