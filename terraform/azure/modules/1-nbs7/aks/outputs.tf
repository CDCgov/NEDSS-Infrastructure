output "kubernetes_cluster_name" {
  value = module.aks.aks_name
}

output "subnet_name" {
  value = try(azurerm_subnet.aks[0].name, data.azurerm_subnet.aks[0].name)
}

output "principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
}

output "key_data" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

output "kubelet_identity_id" {
  value = module.aks.kubelet_identity[0].client_id
}

output "kube_config" {
  value     = module.aks.kube_admin_config_raw
  sensitive = true
}
