module "linkerd" {
  source = "../../modules/3-applications/linkerd"

  resource_group_name = var.resource_group_name
}