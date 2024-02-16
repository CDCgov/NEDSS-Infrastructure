# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get SQL Managed Instance Subnet Data
data "azurerm_subnet" "sqlmi_subnet" {
  name                 = var.sqlmi_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_mssql_managed_instance" "restore_from_database" {
  name                = var.restoring_from_database_name
  resource_group_name = data.azurerm_resource_group.rg.name
}