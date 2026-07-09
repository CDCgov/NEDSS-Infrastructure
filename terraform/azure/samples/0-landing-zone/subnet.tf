locals {
  subnets = {
    "aks" = { # Used by the 'kafka_subnet_name' variable in ../2-nbs7/
      name             = "aks"
      address_prefixes = var.subnet__aks__address_prefixes
    }

    "hdikafka" = { # Used by the 'aks_modern_subnet' variable in ../2-nbs7/
      name                                          = "hdikafka"
      address_prefixes                              = var.subnet__hdikafka__address_prefixes
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
      service_endpoints_with_location = [
        {
          service   = "Microsoft.Storage"
          locations = [var.vnet_location]
        },
        {
          service   = "Microsoft.Sql"
          locations = [var.vnet_location]
        },
        {
          service   = "Microsoft.KeyVault"
          locations = [var.vnet_location]
        },
        {
          service   = "Microsoft.AzureActiveDirectory"
          locations = [var.vnet_location]
        },
      ]

    }

    "endpoint" = { # Used by the 'storage_account_subnet_name' variable in ../2-nbs7/
      name             = "endpoint"
      address_prefixes = var.subnet__endpoint__address_prefixes
    }

    "public_gateways" = { # Used by the 'agw_subnet_name' variable in ../2-nbs7/
      name             = "public_gateways"
      address_prefixes = var.subnet__public_gateways__address_prefixes
      service_endpoints_with_location = [{
        service   = "Microsoft.KeyVault"
        locations = [var.vnet_location]
      }]
    }
  }
}

module "subnet" {
  source = "../../modules/0-landing-zone/vnet/subnet"

  for_each = local.subnets

  resource_group_name  = var.vnet_resource_group_name
  subnet               = each.value
  virtual_network_name = module.vnet.vnet_name
}
