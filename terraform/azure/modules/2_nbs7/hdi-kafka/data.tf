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

#####Data source storage account primary access key  and container id

data "azurerm_storage_account" "kafka_sa_name" {
  name                = var.kafka_storage_account_name
  resource_group_name = var.vnet_rg
}

data "azurerm_storage_container" "kafka_sa_container" {
  name                 = var.kafka_storage_container_name
  storage_account_name = var.kafka_storage_account_name
}

