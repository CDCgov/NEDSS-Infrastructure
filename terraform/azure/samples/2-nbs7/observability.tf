module "observability" {
  source = "../../modules/2-nbs7/observability"

  cluster_name        = var.observability_cluster_name
  resource_group_name = var.vnet_resource_group_name
}
