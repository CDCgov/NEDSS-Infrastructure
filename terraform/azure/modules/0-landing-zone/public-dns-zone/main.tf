resource "azurerm_dns_zone" "public" {
  count               = var.enabled ? 1 : 0
  name                = var.public_domain_name
  resource_group_name = var.resource_group_name
}
