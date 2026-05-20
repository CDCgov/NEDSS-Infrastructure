module "vnet" {
  source = "../../modules/0-landing-zone/vnet"

  parent_id           = var.vnet_parent_id
  vnet_location       = var.vnet_location
  vnet_name           = var.vnet_resource_prefix
  resource_group_name = var.vnet_resource_group_name
}
