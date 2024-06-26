# Re-used variables
locals {
  backend_address_pool_name      = "${var.resource_prefix}-agw-backend-pool"
  frontend_port_name             = "${var.resource_prefix}-agw-frontend-port"
  frontend_port_name_http        = "${var.resource_prefix}-agw-frontend-http-port"
  frontend_ip_configuration_name = "${var.resource_prefix}-agw-frontend-ip-configuration"
  https_setting_name             = "${var.resource_prefix}-agw-backend-https-settings"
  listener_name_https            = "${var.resource_prefix}-agw-https-listener"
  listener_name_http             = "${var.resource_prefix}-agw-http-listener"
  probe_name                     = "${var.resource_prefix}-agw-custom-probe"
  cert_name                      = "${var.resource_prefix}-agw-cert"
  redirect_configuration_name    = "${var.resource_prefix}-agw-redirect-configuration"
  rewrite_rule_set_name          = "${var.resource_prefix}-hsts-rule"
}



### Deploy Public App Gateway ###

# Configure Public IP for App Gateway
### WARNING: IF PUBLIC IP IS CHANGED, A SERVICE NOW TICKET WOULD NEED TO BE SUBMITTED TO CDC OCIO CLOUD TEAM TO UPDATE DNS RECORD ###
resource "azurerm_public_ip" "agw_public_ip" {
  name                = "${var.resource_prefix}-agw-public-ip"
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
    prevent_destroy       = true
    }
}

# Create Managed Identity to allow AGW to read Certificate from KeyVault
resource "azurerm_user_assigned_identity" "agw_mi" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  name                = "${var.resource_prefix}-agw-public-mi"
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




# Create WAF Policy. By default should be blocked on NSG
# resource "azurerm_web_application_firewall_policy" "agw_waf_policy" {
#   name                = "${var.resource_prefix}-waf-policy"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   location            = data.azurerm_resource_group.rg.location

#   managed_rules {
#     managed_rule_set {
#       type    = "OWASP"
#       version = "3.2"
#     }
#   }

#   policy_settings {
#     enabled                     = true
#     mode                        = "Detection"
#     request_body_check          = true
#     file_upload_limit_in_mb     = 100
#     max_request_body_size_in_kb = 128
#   }

#   custom_rules {
#     name      = "Rule1"
#     priority  = 1
#     rule_type = "MatchRule"

#     match_conditions {
#       match_variables {
#         variable_name = "RemoteAddr"
#       }

#       operator           = "IPMatch"
#       negation_condition = false
#       match_values       = ["10.16.3.0/24", "10.16.0.128/26","10.16.2.0/27"]
#     }

#     action = "Allow"
#   }
  
#   lifecycle {
#     ignore_changes = [ 
#       tags["business_steward"],
#       tags["center"],
#       tags["environment"],
#       tags["escid"],
#       tags["funding_source"],
#       tags["pii_data"],
#       tags["security_compliance"],
#       tags["security_steward"],
#       tags["support_group"],
#       tags["system"],
#       tags["technical_poc"],
#       tags["technical_steward"],
#       tags["zone"]
#       ]
#     create_before_destroy = true
#     }
# }

# Configure Public App Gateway
resource "azurerm_application_gateway" "agw_public" {
  name                = "${var.resource_prefix}-agw-public"
  depends_on          = [azurerm_public_ip.agw_public_ip,azurerm_key_vault_access_policy.agw_mi_policy,azurerm_user_assigned_identity.agw_mi]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  # Uncomment if WAF Policy is Required
  # firewall_policy_id  = azurerm_web_application_firewall_policy.agw_waf_policy.id
  
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_mi.id]
  }

  sku {
    # Update name and tier to WAF_v2 if setting WAF Policy
    name     = "Standard_v2"
    tier     = "Standard_v2"
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

  # https listener rule for Https
  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = local.cert_name
  }

  # http listener rule for Http
  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }

  # Request routing rule for Https
  request_routing_rule {
    name                       = "${var.resource_prefix}-agw-rule"
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_https
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.https_setting_name
    rewrite_rule_set_name       = local.rewrite_rule_set_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name_https
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

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  rewrite_rule_set {
      name = local.rewrite_rule_set_name

      rewrite_rule {
        name          = local.rewrite_rule_set_name
        rule_sequence = 100

        response_header_configuration {
          header_name = "Strict-Transport-Security"
          header_value = "max-age=31536000"
        }

      }

    }


  # This should be set if no WAF Policy and only default OWASP rules are required
  # waf_configuration {
  #   enabled               = true
  #   firewall_mode         = "Prevention"
  #   rule_set_type         = "OWASP"
  #   rule_set_version      = "3.2"
  #   request_body_check    = true
  # }

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