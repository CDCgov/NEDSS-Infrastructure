resource "random_id" "prefix" {
  byte_length = 8
}

resource "azurerm_user_assigned_identity" "test" {
  location            = data.azurerm_resource_group.rg.location
  name                = "${random_id.prefix.hex}-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "11.5.0"

  resource_group_name         = data.azurerm_resource_group.rg.name
  cluster_name                = var.k8_cluster_name
  location                    = var.k8_cluster_location
  kubernetes_version          = var.k8_cluster_version
  prefix                      = "prefix"
  agents_availability_zones   = var.node_pool_zones
  auto_scaler_profile_enabled = true
  agents_min_count            = var.node_pool_min_count
  agents_max_count            = var.node_pool_max_count
  temporary_name_for_rotation = var.temporary_name_for_rotation
  vnet_subnet = {
    id = azurerm_subnet.new.id
  }
  network_plugin                    = var.node_pool_network_plugin
  net_profile_pod_cidr              = var.network_profile_pod_cidr
  net_profile_service_cidr          = var.net_profile_service_cidr
  net_profile_dns_service_ip        = var.net_profile_dns_service_ip
  private_cluster_enabled           = false
  rbac_aad_azure_rbac_enabled       = true
  role_based_access_control_enabled = true
  rbac_aad_admin_group_object_ids   = var.rbac_aad_admin_group_object_ids
  identity_ids                      = [azurerm_user_assigned_identity.test.id]
  identity_type                     = var.identity_type
  log_analytics_workspace_enabled   = false

  # Required to be set for integration with monitor/prometheus/grafana, though values are not required to be null.
  monitor_metrics = {
    annotations_allowed = null
    labels_allowed      = null
  }


  #disk_encryption_set_id = azurerm_key_vault_secret.new.id


  /*  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "your-log-analytics-workspace-id"
    }
  } */
  /*
  tags = {
    Environment = "EQ-Dev"
  }
  */
}


