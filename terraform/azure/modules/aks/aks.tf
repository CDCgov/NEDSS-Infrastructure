/*
Not required for now. Saving this for later use. Review and delete this later

# Generate random resource group name
#resource "random_pet" "rg_name" {
#  prefix = var.resource_group_name_prefix
#}

#resource "random_pet" "azurerm_kubernetes_cluster_name" {
#  prefix = "cluster"
#}

#resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
#  prefix = "dns"
#}
*/

data "azuread_service_principal" "akssp"{
    display_name =  var.azuread_service_principal_display_name
}

data "azurerm_resource_group" "rg" {
    name     = var.modern_resource_group_name 
}

resource "azurerm_kubernetes_cluster" "aks" {
  location            = data.azurerm_resource_group.rg.location
  name                = "${var.resource_prefix}-cluster"
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.k8_dns_prefix 

 /* identity {
    type = "SystemAssigned"
  }*/

  storage_profile{
    file_driver_enabled=true
    disk_driver_enabled=false
    snapshot_controller_enabled=false
  }

  oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }

  default_node_pool {
    name                 =  var.default_node_pool_name 
    vm_size              =  var.node_pool_vm_size 
    orchestrator_version =  var.k8_cluster_version    #"1.27.7" 
    #availability_zones   = [1, 2, 3]
    
    zones =  var.node_pool_zones 
    enable_auto_scaling  = true
    max_count            = var.node_pool_max_count #3
    min_count            = var.node_pool_min_count #1
    os_disk_size_gb      = var.node_pool_disk_size_gb #30
    type                 = var.node_pool_type #"VirtualMachineScaleSets"
    vnet_subnet_id        = azurerm_subnet.aks-default.id 
    node_labels = {
      "NodepoolType"    = "system"
      "NodepoolOs"       = "linux"
    } 
   tags = {
      "NodepoolType"    = "system"
      "NodepoolOs"       = "linux"
   } 
  }

  linux_profile {
    admin_username = var.k8_admin_username
    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = var.node_pool_network_plugin #"kubenet"
    load_balancer_sku = var.node_pool_load_balancer_sku #"standard"
   # service_cidr = "10.0.0.0/27"
   # dns_service_ip = "10.0.0.10"
  }

   service_principal {
      client_id = data.azuread_service_principal.akssp.application_id
      client_secret = var.service_principal_client_secret 
      }
}


# Create Linux Azure AKS Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "linux01" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones =  var.node_pool_zones 
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  max_count            = var.node_pool_max_count #3
  min_count            = var.node_pool_min_count #1
  mode                  = "User"
  name                  = var.user_node_pool_name
  orchestrator_version  = var.k8_cluster_version 
  os_disk_size_gb       = var.node_pool_disk_size_gb
  os_type               = "Linux" 
  vm_size               = var.node_pool_vm_size
  priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  vnet_subnet_id        = azurerm_subnet.aks-default.id   
  
  node_labels = {
    "NodepoolType" = "user"
    "NodepoolOs"    = "linux"
  }
  tags = {
    "NodepoolType" = "user"
    "NodepoolOs"    = "linux"
  }
}


resource "random_pet" "aksrandom" {

}