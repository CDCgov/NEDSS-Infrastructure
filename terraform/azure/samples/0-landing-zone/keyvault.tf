module "keyvault" {
  source = "../../modules/0-landing-zone/keyvault"

  name                = "${var.vnet_resource_group_name}-kv"
  location            = var.vnet_location
  resource_group_name = var.vnet_resource_group_name

  firewall_ip_rules = var.keyvault_firewall_ip_rules

  role_assignments = var.keyvault_role_assignments
}
