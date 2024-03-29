# Re-used variables
locals {
  backend_address_pool_name      = "${var.prefix}-agw-backend-pool"
  frontend_port_name             = "${var.prefix}-agw-frontend-port"
  frontend_ip_configuration_name = "${var.prefix}-agw-frontend-ip-configuration"
  https_setting_name              = "${var.prefix}-agw-backend-https-settings"
  listener_name                  = "${var.prefix}-agw-https-listener"
  request_routing_rule_name      = "${var.prefix}-agw-rule"
  probe_name                     = "${var.prefix}-agw-custom-probe"
}



### Deploy Public App Gateway ###

# Configure Public IP for App Gateway
### WARNING: IF PUBLIC IP IS CHANGED, A SERVICE NOW TICKET WOULD NEED TO BE SUBMITTED TO CDC OCIO CLOUD TEAM TO UPDATE DNS RECORD ###
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

# Password is not required
  ssl_certificate {
    name     = "${var.prefix}-agw-cert"
    data     = data.azurerm_key_vault_secret.agw_key_vault_cert.value
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agwpublicip.id
  }

  probe {
    name                = local.probe_name
    protocol            = "Https"
    path                = "/nbs/login"
    host                = var.agw_backend_host
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [var.agw_aks_ip]
  }

  backend_http_settings {
    name                  = local.https_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    probe_name            = local.probe_name
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "${var.prefix}-agw-cert"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.https_setting_name
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