module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm" # Reference info: https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
  version = ">=0.1.7"
  count   = var.enabled ? 1 : 0

  name          = var.vnet_name
  address_space = var.address_space
  location      = var.vnet_location
  parent_id     = var.parent_id
  subnets       = var.subnets
}
