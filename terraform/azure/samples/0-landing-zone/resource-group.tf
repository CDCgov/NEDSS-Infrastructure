module "rg" {
  source = "../../0_landing_zone/resource_group"

  enabled             = var.rg_enabled
  resource_group_name = var.resource_group_name
  location            = var.location
}
