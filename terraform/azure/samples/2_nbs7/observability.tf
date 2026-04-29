module "observability" {
  source = "../../modules/2_nbs7/observability"

  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group_name
}
