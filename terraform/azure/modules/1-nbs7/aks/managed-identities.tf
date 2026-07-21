resource "azurerm_user_assigned_identity" "cert_manager" {
  count               = var.enable_cert_manager ? 1 : 0
  name                = "cert-manager-identity"
  resource_group_name = var.modern_resource_group_name
  location            = var.k8_cluster_location
}

resource "azurerm_role_assignment" "cert_manager_dns" {
  count                = var.enable_cert_manager ? 1 : 0
  scope                = var.dns_zone_id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager[count.index].principal_id
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  count               = var.enable_cert_manager ? 1 : 0
  name                = "cert-manager-federation"
  resource_group_name = var.modern_resource_group_name
  parent_id           = azurerm_user_assigned_identity.cert_manager[count.index].id

  issuer = module.aks.oidc_issuer_url

  subject  = "system:serviceaccount:cert-manager:cert-manager"
  audience = ["api://AzureADTokenExchange"]
}

