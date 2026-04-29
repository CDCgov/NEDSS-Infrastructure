module "vnet" {
  source = "../..//modules/0_landing_zone/vnet"

  parent_id           = var.parent_id
  vnet_location       = var.vnet_location
  vnet_name           = var.resource_prefix
  resource_group_name = var.resource_group_name
}
