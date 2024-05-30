# Get Resource Group Data
data "azurerm_resource_group" "rg" {
  name     = var.aci_resource_group_name
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.aci_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Get ACI Subnet Data
data "azurerm_subnet" "aci_subnet" {
  name                 = var.aci_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

# Get SQL Managed Instance Endpoint
data "azurerm_sql_managed_instance" "sqlmi_endpoint" {
  name                = "${var.resource_prefix}-sql-managed-instance"
  resource_group_name = data.azurerm_resource_group.rg.name
}