resource "random_id" "prefix" {
  byte_length = 8
}

data "azurerm_resource_group" "rg" {
  name = var.modern_resource_group_name
}


resource "azurerm_user_assigned_identity" "test" {
  location            = data.azurerm_resource_group.rg.location
  name                = "${random_id.prefix.hex}-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "7.5.0"

  resource_group_name               = data.azurerm_resource_group.rg.name
  cluster_name                      = var.k8_cluster_name
  location                          = var.k8_cluster_location
  kubernetes_version                = var.k8_cluster_version
  prefix                            = "prefix"
  agents_availability_zones         = var.node_pool_zones
  enable_auto_scaling               = true
  agents_min_count                  = var.node_pool_min_count
  agents_max_count                  = var.node_pool_max_count
  temporary_name_for_rotation       = var.temporary_name_for_rotation
  vnet_subnet_id                    = azurerm_subnet.new.id
  network_plugin                    = var.node_pool_network_plugin
  net_profile_pod_cidr              = var.network_profile_pod_cidr
  private_cluster_enabled           = false
  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true
  identity_ids                      = [azurerm_user_assigned_identity.test.id]
  identity_type                     = var.identity_type

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


/*

data "azurerm_resource_group" "rg" {
    name     = var.modern_resource_group_name 
}

data "azuread_service_principal" "akssp"{
    display_name =  var.azuread_service_principal_display_name
}

# Create AKS cluster
module "aks" {
  prefix = "prefix"
  source = "Azure/aks/azurerm"
  version = "7.5.0"
  resource_group_name = data.azurerm_resource_group.rg.name  #azurerm_resource_group.rg.name
  location           = data.azurerm_resource_group.rg.location
  cluster_name       =  "cdc-nbs-eq-cluter"  #"${var.resource_prefix}-cluster"
  kubernetes_version = "1.27.7" #var.k8_cluster_version 
  log_analytics_workspace_enabled      = false
  role_based_access_control_enabled = false

}

*/
#acr_integration_enabled = true
#acr_id                  = azurerm_container_registry.acr.id
#rbac_enabled            = true
#enable_ingress          = true
#enable_files_pv         = true

#default_node_pool_enabled = true
#default_node_pool_vm_size = "Standard_DS2_v2"
#default_node_pool_min_count = 1
#default_node_pool_max_count = 3

#user_node_pool_enabled = true
#user_node_pool_name = "userpool"
#user_node_pool_vm_size = "Standard_DS2_v2"
#user_node_pool_min_count = 1
#user_node_pool_max_count = 3  

/*
  service_principal {
      client_id = data.azuread_service_principal.akssp.application_id
      client_secret = var.service_principal_client_secret 
      }
  */




