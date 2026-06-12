resource "azurerm_key_vault" "this" {
  count               = var.enabled ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id != null ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  rbac_authorization_enabled      = var.enable_rbac_authorization

  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = length(var.firewall_ip_rules) > 0 || length(var.firewall_virtual_network_subnet_ids) > 0 ? [1] : []
    content {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = var.firewall_ip_rules
      virtual_network_subnet_ids = var.firewall_virtual_network_subnet_ids
    }
  }


  tags = var.tags
}

# Access policies (only used when enable_rbac_authorization = false)
resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.enabled && var.enable_rbac_authorization ? {} : var.access_policies

  key_vault_id = azurerm_key_vault.this[0].id
  tenant_id    = lookup(each.value, "tenant_id", data.azurerm_client_config.current.tenant_id)
  object_id    = each.value.object_id

  key_permissions         = lookup(each.value, "key_permissions", [])
  secret_permissions      = lookup(each.value, "secret_permissions", [])
  certificate_permissions = lookup(each.value, "certificate_permissions", [])
  storage_permissions     = lookup(each.value, "storage_permissions", [])
}

# RBAC role assignments (only used when enable_rbac_authorization = true)
resource "azurerm_role_assignment" "this" {
  for_each = var.enabled && var.enable_rbac_authorization ? var.role_assignments : {}

  scope          = azurerm_key_vault.this[0].id
  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type
  description    = each.value.description

  # Accept either a plain built-in role name ("Key Vault Secrets Officer")
  # or a full role definition resource ID for custom roles.
  role_definition_name = can(regex("^/", each.value.role)) ? null : each.value.role
  role_definition_id   = can(regex("^/", each.value.role)) ? each.value.role : null
}

resource "azurerm_private_endpoint" "this" {
  count = var.enabled && var.private_endpoint != null ? 1 : 0

  name                = coalesce(var.private_endpoint.name, "${var.name}-pe")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = coalesce(var.private_endpoint.connection_name, "${var.name}-psc")
    private_connection_resource_id = azurerm_key_vault.this[count.index].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
    }
  }

  tags = var.tags
}
