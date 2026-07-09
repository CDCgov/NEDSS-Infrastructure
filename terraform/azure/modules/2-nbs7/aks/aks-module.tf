resource "random_id" "prefix" {
  byte_length = 8
}

resource "azurerm_user_assigned_identity" "aks" {
  location            = data.azurerm_resource_group.rg.location
  name                = "${random_id.prefix.hex}-identity"
  resource_group_name = data.azurerm_resource_group.rg.name

  lifecycle {
    ignore_changes = [location]
  }
}

module "aks" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/azure/modules/vendor/Azure/terraform-azurerm-aks/?depth=1&ref=v1.2.48" # TO-DO change this ref to v7.13.0

  auto_scaling_enabled        = var.auto_scaling_enabled
  resource_group_name         = data.azurerm_resource_group.rg.name
  cluster_name                = "${var.resource_prefix}-aks"
  location                    = var.k8_cluster_location
  kubernetes_version          = var.k8_cluster_version
  prefix                      = var.resource_prefix
  agents_availability_zones   = var.node_pool_zones
  auto_scaler_profile_enabled = true
  agents_min_count            = var.node_pool_min_count
  agents_max_count            = var.node_pool_max_count
  temporary_name_for_rotation = var.temporary_name_for_rotation
  vnet_subnet = {
    id = try(azurerm_subnet.aks[0].id, data.azurerm_subnet.aks[0].id)
  }
  network_plugin                    = var.node_pool_network_plugin
  net_profile_pod_cidr              = var.network_profile_pod_cidr
  net_profile_service_cidr          = var.net_profile_service_cidr
  net_profile_dns_service_ip        = var.net_profile_dns_service_ip
  private_cluster_enabled           = false
  rbac_aad_azure_rbac_enabled       = true
  role_based_access_control_enabled = true
  rbac_aad_admin_group_object_ids   = var.rbac_aad_admin_group_object_ids
  identity_ids                      = [azurerm_user_assigned_identity.aks.id]
  identity_type                     = var.identity_type
  log_analytics_workspace_enabled   = false
  os_sku                            = var.os_sku

  # Required to be set for integration with monitor/prometheus/grafana, though values are not required to be null.
  monitor_metrics = {
    annotations_allowed = null
    labels_allowed      = null
  }
}
