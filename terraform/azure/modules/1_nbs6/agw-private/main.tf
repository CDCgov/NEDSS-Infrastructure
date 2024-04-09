# Re-used variables
locals {
  backend_address_pool_name      = "${var.resource_prefix}-agw-backend-pool"
  frontend_port_name             = "${var.resource_prefix}-agw-frontend-port"
  frontend_port_name_http        = "${var.resource_prefix}-agw-frontend-http-port"
  frontend_ip_configuration_name = "${var.resource_prefix}-agw-frontend-ip-configuration"
  https_setting_name             = "${var.resource_prefix}-agw-backend-https-settings"
  listener_name                  = "${var.resource_prefix}-agw-https-listener"
  listener_name_http             = "${var.resource_prefix}-agw-http-listener"
  request_routing_rule_name      = "${var.resource_prefix}-agw-rule"
  probe_name                     = "${var.resource_prefix}-agw-custom-probe"
  cert_name                      = "${var.resource_prefix}-agw-cert"
  redirect_configuration_name    = "${var.resource_prefix}-agw-redirect-configuration"
  waf_policy_name                = "${var.resource_prefix}-waf-policy"
}



### Deploy Public App Gateway ###

# Configure Public IP for App Gateway
### NOTE: This required by Azure for AGW even if keeping traffic private. ###
### This will not be needed once Private Application Gateway is out of preview https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=portal ###
resource "azurerm_public_ip" "agw_public_ip" {
  name                = "${var.resource_prefix}-agw-temp-public-ip"
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

# Create Managed Identity to allow AGW to read Certificate from KeyVault
resource "azurerm_user_assigned_identity" "agw_mi" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  name                = "${var.resource_prefix}-agw-private-mi"
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

# Create Managed Identity to allow AGW to read Certificate from KeyVault
resource "azurerm_key_vault_access_policy" "agw_mi_policy" {
  depends_on         = [azurerm_user_assigned_identity.agw_mi]
  key_vault_id       = data.azurerm_key_vault.key_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.agw_mi.principal_id
  secret_permissions = ["Get","List"]
}


# Create if WAF Policy to only allow vNET Traffic only
resource "azurerm_web_application_firewall_policy" "agw_waf_policy" {
  name                = local.waf_policy_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

 managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

 custom_rules {
    name      = "Rule1"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["10.16.3.0/24", "10.16.0.128/26","10.16.2.0/27"]
    }

    action = "Allow"
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
    create_before_destroy = true
    }
}


# Configure Public App Gateway
resource "azurerm_application_gateway" "agw_private" {
  name                = "${var.resource_prefix}-agw-private"
  depends_on          = [azurerm_public_ip.agw_public_ip,azurerm_key_vault_access_policy.agw_mi_policy,azurerm_user_assigned_identity.agw_mi]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.agw_waf_policy.id
  
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_mi.id]
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.resource_prefix}-agw-frontend-ip-configuration"
    subnet_id = data.azurerm_subnet.agw_subnet.id
  }


# Password is not required
  ssl_certificate {
    name                    = local.cert_name
    key_vault_secret_id     = data.azurerm_key_vault_secret.agw_key_vault_cert.id
  }

  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }


  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw_public_ip.id
  }

  frontend_ip_configuration {
    name                          = "${local.frontend_ip_configuration_name}-private"
    private_ip_address            = var.agw_private_ip
    private_ip_address_allocation = "Static"
    subnet_id                     = data.azurerm_subnet.agw_subnet.id
  }

  probe {
    name                = local.probe_name
    protocol            = "Http"
    path                = "/nbs/login"
    host                = var.agw_backend_host
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.agw_aci_ip
  }

  backend_http_settings {
    name                  = local.https_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 7001
    protocol              = "Http"
    probe_name            = local.probe_name
  }

  # https listener rule for Https
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-private"
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = local.cert_name
  }

  # http listener rule for Http
  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-private"
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }

  # Request routing rule for Https
  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.https_setting_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name
    include_path         = true
    include_query_string = true
  }

  # Request routing rule for Http
  request_routing_rule {
    name                        = "${var.resource_prefix}-agw-rule-http"
    priority                    = 1
    rule_type                   = "Basic"
    http_listener_name          = local.listener_name_http
    redirect_configuration_name = local.redirect_configuration_name
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