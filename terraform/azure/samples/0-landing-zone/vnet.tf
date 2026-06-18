module "vnet" {
  source = "../../modules/0-landing-zone/vnet"

  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  vnet_location       = var.vnet_location
  resource_group_name = var.vnet_resource_group_name
  parent_id           = var.vnet_resource_group_id
}
