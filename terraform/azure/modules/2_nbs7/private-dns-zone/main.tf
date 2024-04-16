data "azurerm_resource_group" "main" {
  name                = var.resource_group_name 
}

resource "azurerm_private_dns_zone" "private_dns_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone" "private_dns_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
}