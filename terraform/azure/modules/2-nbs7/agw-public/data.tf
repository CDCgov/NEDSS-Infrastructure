# Get Client Config
data "azurerm_client_config" "current" {}

# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  count = var.enabled ? 1 : 0
  name  = var.agw_resource_group_name
}

# Get SSL Certificate KeyVault Resource Group Data
data "azurerm_resource_group" "key_vault_cert_rg" {
  count = var.enabled ? 1 : 0
  name  = var.agw_key_vault_cert_rg
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  count               = var.enabled ? 1 : 0
  name                = var.agw_vnet_name
  resource_group_name = data.azurerm_resource_group.rg[0].name
}

# Get App Gateway Subnet Data
data "azurerm_subnet" "agw_subnet" {
  count                = var.enabled ? 1 : 0
  name                 = var.agw_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = data.azurerm_virtual_network.vnet[0].resource_group_name
}

# Get KeyVault Id
data "azurerm_key_vault" "key_vault" {
  count               = var.enabled ? 1 : 0
  name                = var.agw_key_vault_name
  resource_group_name = data.azurerm_resource_group.key_vault_cert_rg[0].name
}

# Get Certificate from KeyVault
data "azurerm_key_vault_secret" "agw_key_vault_cert_public" {
  count        = var.enabled ? 1 : 0
  name         = var.agw_key_vault_cert_name_public
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
}

data "azurerm_key_vault_secret" "agw_key_vault_cert_private" {
  count        = var.enabled && var.enable_dual_gateway ? 1 : 0
  name         = var.agw_key_vault_cert_name_private
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
}