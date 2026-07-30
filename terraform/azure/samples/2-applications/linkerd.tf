module "linkerd" {
  source = "../../modules/2-applications/linkerd"

  resource_group_name        = var.vnet_resource_group_name
  aks_cluster_name           = var.linkerd_aks_cluster_name
  linkerd_repository         = var.linkerd_repository
  linkerd_chart              = var.linkerd_chart
  linkerd_namespace_name     = var.linkerd_namespace_name
  linkerd_controlplane_chart = var.linkerd_controlplane_chart
  linkerd_viz_chart          = var.linkerd_viz_chart
  linkerd_viz_namespace_name = var.linkerd_viz_namespace_name
  create_linkerd_viz         = var.linkerd_create_linkerd_viz

}