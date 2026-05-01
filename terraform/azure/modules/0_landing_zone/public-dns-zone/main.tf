resource "azurerm_dns_zone" "public" {
  name                = var.public_domain_name
  resource_group_name = var.resource_group_name
}
