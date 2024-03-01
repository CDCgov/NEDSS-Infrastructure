/*
output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = module.aks.name
}

output "client_certificate" {
  value     = module.aks.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = module.aks.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = module.aks.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = module.aks.kube_config[0].host
  sensitive = true
}


output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
*/