/*resource "azurerm_container_registry" "acr" {
    #need random name
  name                =  "${var.container_registry_name}${random_string.acr_suffix.result}"  
  #"cdcnbsregistry"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.container_registry_sku
  #"Standard"
  admin_enabled       = var.container_registry_admin_enabled
  public_network_access_enabled   =  false
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

resource "random_string" "acr_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

*/

/*
resource "random_string" "acr_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

resource "azurerm_container_registry" "example" {
  location            = local.resource_group.location
  name                = "aksacrtest${random_string.acr_suffix.result}"
  resource_group_name = local.resource_group.name
  sku                 = "Premium"

  retention_policy {
    days    = 7
    enabled = true
  }
}
*/