module "aks_nbs7" {
  source = "../../modules/2_nbs7/aks"

  k8_cluster_name                 = var.k8_cluster_name
  k8_cluster_version              = var.k8_cluster_version
  modern_resource_group_name      = var.modern_resource_group_name
  modern_subnet                   = var.modern_subnet
  rbac_aad_admin_group_object_ids = var.rbac_aad_admin_group_object_ids
  resource_prefix                 = var.resource_prefix
}
