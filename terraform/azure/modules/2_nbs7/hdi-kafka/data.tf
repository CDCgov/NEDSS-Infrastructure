# Get resource group
data "azurerm_resource_group" "rg" {
  name = var.vnet_rg # "csels-nbs-dev-low-rg"
}

# Get vNet Data
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

# Get Kafka Subnet Data
data "azurerm_subnet" "kafka_subnet_name" {
  name                 = var.kafka_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}
