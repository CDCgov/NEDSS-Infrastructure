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

#VNET Link
data "azurerm_virtual_network" "vnet" {
    for_each = toset(var.virtual_network_name)
    name = each.key
    resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_blob" {
  for_each = data.azurerm_virtual_network.vnet
  name                  = "${each.value.name}-blob-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_blob.name
  virtual_network_id    = each.value.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_file" {  
  for_each = data.azurerm_virtual_network.vnet
  name                  = "${each.value.name}-file-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_file.name
  virtual_network_id    = each.value.id  
}