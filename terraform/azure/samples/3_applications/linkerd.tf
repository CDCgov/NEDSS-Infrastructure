module "linkerd" {
  source = "../../modules/3_applications/linkerd"

  resource_group_name = var.resource_group_name
}