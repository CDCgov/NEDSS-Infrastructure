/*resource "azurerm_container_registry" "acr" {
    #need random name
  name                = "cdcnbsregistry"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}*/


module acr{
  source = "../modules/acr"
  container_registry_name = var.container_registry_name
  container_registry_sku = var.container_registry_sku
  container_registry_resource_group_name = var.container_registry_resource_group_name
  service_principal_name = var.service_principal_name 
}