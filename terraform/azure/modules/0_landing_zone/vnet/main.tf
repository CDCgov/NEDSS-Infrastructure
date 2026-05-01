module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">=0.1.7"

  parent_id = var.parent_id
  location  = var.vnet_location
  name      = "${var.vnet_name}-nbs7"

  address_space = ["10.1.0.0/16"]

  subnets = {
    "vms" = {
      name             = "vms"
      address_prefixes = ["10.1.0.0/20"]
    }

    "endpoint" = {
      name             = "endpoint"
      address_prefixes = ["10.1.16.0/20"]
    }

    "gateways" = {
      name             = "gateways"
      address_prefixes = ["10.1.48.0/24"]
      service_endpoints_with_location = [{
        service   = "Microsoft.KeyVault"
        locations = [data.azurerm_resource_group.rg.location]
      }]
    }
  }

}