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

resource "azurerm_user_assigned_identity" "data_compare" {
  count               = var.create_datacompare_resources ? 1 : 0
  name                = "data-compare-identity"
  resource_group_name = var.modern_resource_group_name
  location            = var.k8_cluster_location
}

resource "azurerm_federated_identity_credential" "data_compare" {
  for_each            = var.create_datacompare_resources ? var.datacompare_namespace_and_service : {}
  name                = "${each.value.namespace}-${each.value.service}-federation"
  resource_group_name = var.modern_resource_group_name
  parent_id           = azurerm_user_assigned_identity.data_compare[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.service}"
}

resource "azurerm_role_assignment" "data_compare" {
  count                = var.create_datacompare_resources ? 1 : 0
  scope                = azurerm_storage_container.data_compare[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.data_compare[0].principal_id
}

resource "azurerm_user_assigned_identity" "otel_collector" {
  count               = var.create_otel_collector_resources ? 1 : 0
  name                = "otel-collector-identity"
  resource_group_name = var.modern_resource_group_name
  location            = var.k8_cluster_location
}

resource "azurerm_federated_identity_credential" "otel_collector" {
  for_each            = var.create_otel_collector_resources ? var.datacompare_namespace_and_service : {}
  name                = "${each.value.namespace}-${each.value.service}-federation"
  resource_group_name = var.modern_resource_group_name
  parent_id           = azurerm_user_assigned_identity.otel_collector[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.service}"
}

resource "azurerm_role_assignment" "otel_collector" {
  count                = var.create_otel_collector_resources ? 1 : 0
  scope                = azurerm_storage_container.otel_collector[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.otel_collector[0].principal_id
}


