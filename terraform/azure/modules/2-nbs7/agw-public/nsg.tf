locals {
  authorized_ips = {
    for idx, val in sort(length(var.nsg_akamai_ips) > 0 ? (
    var.nsg_akamai_ips) : ["*"]) : val => idx
  }
}

resource "azurerm_network_security_group" "nsg" {
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-nsg-public-agw"
  resource_group_name = data.azurerm_resource_group.rg[0].name
  location            = data.azurerm_resource_group.rg[0].location

  lifecycle {
    ignore_changes = [
      tags["business_steward"],
      tags["center"],
      tags["environment"],
      tags["escid"],
      tags["funding_source"],
      tags["pii_data"],
      tags["security_compliance"],
      tags["security_steward"],
      tags["support_group"],
      tags["system"],
      tags["technical_poc"],
      tags["technical_steward"],
      tags["zone"]
    ]
  }
}

resource "azurerm_network_security_rule" "allow_agw_frontend_traffic" {
  for_each          = var.enabled ? local.authorized_ips : {}
  name              = "Allow-Traffic-To-AGW-Frontends-${each.value}"
  priority          = 100 + each.value
  direction         = "Inbound"
  access            = "Allow"
  protocol          = "Tcp"
  source_port_range = "*"

  destination_port_ranges = ["80", "443"]

  source_address_prefix = each.key

  destination_address_prefixes = [
    azurerm_public_ip.agw_public_ip[0].ip_address,
    var.agw_private_ip
  ]

  resource_group_name         = var.agw_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "allow_gateway_manager" {
  count                       = var.enabled ? 1 : 0
  name                        = "Allow-GatewayManager-Inbound"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.agw_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[count.index].name
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association" {
  count                     = var.enabled ? 1 : 0
  subnet_id                 = data.azurerm_subnet.agw_subnet[0].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}
