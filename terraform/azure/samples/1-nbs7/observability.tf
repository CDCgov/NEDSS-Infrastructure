module "observability" {
  source = "../../modules/1-nbs7/observability"

  resource_prefix              = local.observability_resource_prefix
  resource_group_name          = var.vnet_resource_group_name
  location                     = var.vnet_location
  update_admin_role_assignment = var.observability_update_admin_role_assignment
  grafana_major_version        = var.observability_grafana_major_version
  cluster_name                 = "${local.aks_resource_prefix}-aks"

  depends_on = [module.aks_nbs7]
}
