module "acr" {
  source = "../../modules/0_landing_zone/acr-private"

  resource_prefix         = var.resource_prefix
  acr_resource_group_name = var.acr_resource_group_name
  acr_vnet_name           = var.acr_vnet_name
  acr_subnet_name         = var.acr_subnet_name
}
