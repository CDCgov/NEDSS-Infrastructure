module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">=0.1.7"

  parent_id     = var.parent_id
  location      = var.vnet_location
  name          = var.vnet_name
  address_space = var.address_space
  subnets       = length(var.subnets) > 0 ? var.subnets : local.subnets

}