# Re-used variables
locals {
  backend_address_pool_name      = "${var.prefix}-agw-backend-pool"
  frontend_port_name             = "${var.prefix}-agw-frontend-port"
  frontend_ip_configuration_name = "${var.prefix}-agw-frontend-ip-configuration"
  http_setting_name              = "${var.prefix}-agw-backend-http-settings"
  listener_name                  = "${var.prefix}-agw-http-listener"
  request_routing_rule_name      = "${var.prefix}-agw-rule"
  probe_name                     = "${var.prefix}-agw-custom-probe"
}


### Deploy Public App Gateway ###

# Configure Public IP for App Gateway
# Might be best to level 1 app infrastrcuture deployment
resource "azurerm_public_ip" "agwpublicip" {
  name                = "${var.prefix}-agw-public-ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
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
    create_before_destroy = true
    }
}


# Configure Public App Gateway
resource "azurerm_application_gateway" "agw-public" {
  name                = "${var.prefix}-agw-public"
  depends_on          = [azurerm_public_ip.agwpublicip]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.prefix}-agw-ip-configuration"
    subnet_id = data.azurerm_subnet.agw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agwpublicip.id
  }

  probe {
    name                = local.probe_name
    protocol            = "Http"
    path                = "/nbs/login"
    host                = "localhost"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.agw_aci_ip_list
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 7001
    protocol              = "Http"
    probe_name            = local.probe_name
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
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