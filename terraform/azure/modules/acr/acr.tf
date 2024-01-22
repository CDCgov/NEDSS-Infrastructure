resource "azurerm_container_registry" "acr" {
    #need random name
  name                =  var.container_registry_name   
  #"cdcnbsregistry"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.container_registry_sku
  #"Standard"
  admin_enabled       = var.container_registry_admin_enabled
}


data "azuread_service_principal" "akssp"{
    display_name =  var.service_principal_name
    #"cdc-nbs-server-principal"
}


resource "azurerm_role_assignment" "aks_to_acr_role" {
  principal_id                     = data.azuread_service_principal.akssp.object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


data "azurerm_resource_group" "rg" {
  name     = var.container_registry_resource_group_name
  #"cdc-nbs-modern-rg"
}
