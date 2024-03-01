# Re-used variables
locals {
  backend_address_pool_name      = "${var.prefix}-appgw-backend-pool"
  frontend_port_name             = "${var.prefix}-appgw-frontend-port"
  frontend_ip_configuration_name = "${var.prefix}-appgw-frontend-ip-configuration"
  http_setting_name              = "${var.prefix}-appgw-backend-http-settings"
  listener_name                  = "${var.prefix}-appgw-http-listener"
  request_routing_rule_name      = "${var.prefix}-appgw-rule"
  probe_name                     = "${var.prefix}-appgw-custom-probe"
}


### Deploy NBS6 in ACI ###
resource "azurerm_container_group" "aci" {
  name                = "${var.prefix}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Windows"
  ip_address_type     = "Private"
  subnet_ids          = toset([data.azurerm_subnet.aci_subnet.id])

  container {
    name   = "${var.prefix}-container"
    image  = var.quay_nbs6_repository
    cpu    = 4
    memory = 8
    ports {
      port     = 7001
      protocol = "TCP"
    }

    environment_variables = {
      DATABASE_ENDPOINT = var.sql_database_endpoint
    }

  }
}


### Deploy App Gateway for ACI ###


# Configure Public IP for App Gateway
# Might be best to level 1 app infrastrcuture deployment
resource "azurerm_public_ip" "appgwpublicip" {
  name                = "${var.prefix}-appgw-public-ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


# Configure App Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  depends_on          = [azurerm_public_ip.appgwpublicip]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.prefix}-appgw-ip-configuration"
    subnet_id = data.azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgwpublicip.id
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
    ip_addresses = var.aci_ip_list
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
}