# Re-used variables
locals {
  # --- Shared ---
  frontend_ip_configuration_name_public  = "${var.resource_prefix}-agw-frontend-ip-public"
  frontend_ip_configuration_name_private = "${var.resource_prefix}-agw-frontend-ip-private"
  frontend_port_name                     = "${var.resource_prefix}-agw-frontend-port"
  frontend_port_name_http                = "${var.resource_prefix}-agw-frontend-http-port"

  # --- NBS 7 ---
  backend_address_pool_name_public = "${var.resource_prefix}-agw-backend-pool-public"
  https_setting_name_public        = "${var.resource_prefix}-agw-backend-https-settings-public"
  listener_name_https_public       = "${var.resource_prefix}-agw-https-listener-public"
  listener_name_http_public        = "${var.resource_prefix}-agw-http-listener-public"
  probe_name_public                = "${var.resource_prefix}-agw-probe-public"
  cert_name_public                 = "${var.resource_prefix}-agw-cert-public"
  redirect_config_name_public      = "${var.resource_prefix}-agw-redirect-public"
  rewrite_rule_set_name            = "${var.resource_prefix}-hsts-rule"

  # --- NBS 6 ---
  backend_address_pool_name_private = "${var.resource_prefix}-agw-backend-pool-private"
  https_setting_name_private        = "${var.resource_prefix}-agw-backend-https-settings-private"
  listener_name_https_private       = "${var.resource_prefix}-agw-https-listener-private"
  listener_name_http_private        = "${var.resource_prefix}-agw-http-listener-private"
  probe_name_private                = "${var.resource_prefix}-agw-probe-private"
  cert_name_private                 = "${var.resource_prefix}-agw-cert-private"
  redirect_config_name_private      = "${var.resource_prefix}-agw-redirect-private"
}

resource "azurerm_public_ip" "agw_public_ip" {
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-agw-public-ip"
  resource_group_name = data.azurerm_resource_group.rg[0].name
  location            = data.azurerm_resource_group.rg[0].location
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
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-agw-public-mi"
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
    create_before_destroy = true
  }
}

resource "azurerm_key_vault_access_policy" "agw_mi_policy" {
  count              = var.enabled ? 1 : 0
  key_vault_id       = data.azurerm_key_vault.key_vault[0].id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.agw_mi[count.index].principal_id
  secret_permissions = ["Get", "List"]

  depends_on = [azurerm_user_assigned_identity.agw_mi]
}

resource "azurerm_role_assignment" "agw" {
  count                = var.enabled && var.role_based_kv ? 1 : 0
  scope                = data.azurerm_key_vault.key_vault[0].id
  role_definition_name = var.agw_role_definition_name
  principal_id         = azurerm_user_assigned_identity.agw_mi[count.index].principal_id
}


resource "azurerm_application_gateway" "agw_public" {
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-agw-public"
  resource_group_name = data.azurerm_resource_group.rg[0].name
  location            = data.azurerm_resource_group.rg[0].location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_mi[count.index].id]
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.resource_prefix}-agw-ip-configuration"
    subnet_id = data.azurerm_subnet.agw_subnet[0].id
  }

  # ---------------------------------------------------------------
  # Frontend IPs
  # ---------------------------------------------------------------
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name_public
    public_ip_address_id = azurerm_public_ip.agw_public_ip[count.index].id
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name_private
    private_ip_address            = var.agw_private_ip
    private_ip_address_allocation = "Static"
    subnet_id                     = data.azurerm_subnet.agw_subnet[0].id
  }

  # Shared ports
  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  # ---------------------------------------------------------------
  # Certificates — one per app (add private cert to the same KV)
  # ---------------------------------------------------------------
  ssl_certificate {
    name                = local.cert_name_public
    key_vault_secret_id = data.azurerm_key_vault_secret.agw_key_vault_cert_public[0].id
  }

  dynamic "ssl_certificate" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                = local.cert_name_private
      key_vault_secret_id = data.azurerm_key_vault_secret.agw_key_vault_cert_private[0].id
    }
  }

  # ---------------------------------------------------------------
  # NBS 7
  # ---------------------------------------------------------------
  probe {
    name                = local.probe_name_public
    protocol            = "Https"
    path                = "/nbs/login"
    host                = var.agw_app_backend_host
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name_public
    ip_addresses = [var.agw_aks_ip]
  }

  backend_http_settings {
    name                  = local.https_setting_name_public
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    probe_name            = local.probe_name_public
  }

  http_listener {
    name                           = local.listener_name_https_public
    frontend_ip_configuration_name = local.frontend_ip_configuration_name_public
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = local.cert_name_public
    host_names = [
      var.agw_app_public_hostname,
      var.agw_data_public_hostname,
    ]
  }

  http_listener {
    name                           = local.listener_name_http_public
    frontend_ip_configuration_name = local.frontend_ip_configuration_name_public
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
    host_names = [
      var.agw_app_public_hostname,
      var.agw_data_public_hostname,
    ]
  }

  redirect_configuration {
    name                 = local.redirect_config_name_public
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name_https_public
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = "${var.resource_prefix}-agw-rule-public"
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_https_public
    backend_address_pool_name  = local.backend_address_pool_name_public
    backend_http_settings_name = local.https_setting_name_public
    rewrite_rule_set_name      = local.rewrite_rule_set_name
  }

  request_routing_rule {
    name                        = "${var.resource_prefix}-agw-rule-public-http"
    priority                    = 5
    rule_type                   = "Basic"
    http_listener_name          = local.listener_name_http_public
    redirect_configuration_name = local.redirect_config_name_public
  }

  # ---------------------------------------------------------------
  # NBS 6
  # ---------------------------------------------------------------
  dynamic "probe" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                = local.probe_name_private
      protocol            = "Http"
      path                = "/nbs/login"
      host                = var.agw_private_backend_host
      interval            = 30
      timeout             = 30
      unhealthy_threshold = 3
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name         = local.backend_address_pool_name_private
      ip_addresses = [var.agw_nbs_ip_private]
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                  = local.https_setting_name_private
      cookie_based_affinity = "Disabled"
      path                  = "/"
      port                  = 7001
      protocol              = "Http"
      probe_name            = local.probe_name_private
    }
  }

  dynamic "http_listener" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                           = local.listener_name_https_private
      frontend_ip_configuration_name = local.frontend_ip_configuration_name_private
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Https"
      ssl_certificate_name           = local.cert_name_private
      host_name                      = var.agw_private_hostname
    }
  }

  dynamic "http_listener" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                           = local.listener_name_http_private
      frontend_ip_configuration_name = local.frontend_ip_configuration_name_private
      frontend_port_name             = local.frontend_port_name_http
      protocol                       = "Http"
      host_name                      = var.agw_private_hostname
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                 = local.redirect_config_name_private
      redirect_type        = "Permanent"
      target_listener_name = local.listener_name_https_private
      include_path         = true
      include_query_string = true
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                       = "${var.resource_prefix}-agw-rule-private"
      priority                   = 20
      rule_type                  = "Basic"
      http_listener_name         = local.listener_name_https_private
      backend_address_pool_name  = local.backend_address_pool_name_private
      backend_http_settings_name = local.https_setting_name_private
      rewrite_rule_set_name      = local.rewrite_rule_set_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.enable_dual_gateway ? [1] : []
    content {
      name                        = "${var.resource_prefix}-agw-rule-private-http"
      priority                    = 15
      rule_type                   = "Basic"
      http_listener_name          = local.listener_name_http_private
      redirect_configuration_name = local.redirect_config_name_private
    }
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
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000"
      }
    }
  }

  depends_on = [
    azurerm_public_ip.agw_public_ip[0],
    azurerm_key_vault_access_policy.agw_mi_policy[0],
    azurerm_user_assigned_identity.agw_mi
  ]


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
