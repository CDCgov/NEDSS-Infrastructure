#NOTE: THIS WILL BE CREATED BY CDC CLOUD TEAM IF DEPLOYING IN CDC AZURE EXT

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = "${var.resource_prefix}acrprivateacr"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sku                           = "Premium"   # Premium SKU is required for private endpoints
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  admin_enabled                 = true # Required for ACI to pull image
  retention_policy              = [{
    enabled = true
    days    = 30
  }]
  anonymous_pull_enabled        = true
  export_policy_enabled         = false
}
 
# Private endpoint for ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${var.resource_prefix}-acr-ep"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.acr_subnet.id
 
  private_service_connection {
    name                           = "${var.resource_prefix}-acr-ep"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}