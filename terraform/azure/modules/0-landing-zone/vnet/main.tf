module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">=0.1.7"
  count   = var.enabled ? 1 : 0

  parent_id     = var.parent_id
  location      = var.vnet_location
  name          = var.vnet_name
  address_space = var.address_space
  subnets       = var.subnets
}