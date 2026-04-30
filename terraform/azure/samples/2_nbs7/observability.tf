module "observability" {
  source = "../../modules/2_nbs7/observability"

  cluster_name        = var.observability_cluster_name
  resource_group_name = var.observability_resource_group_name
}
