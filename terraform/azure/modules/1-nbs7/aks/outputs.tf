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

output "data_compare_identity_client_id" {
  description = "Client ID to set as the azure.workload.identity/client-id annotation on the Kubernetes service account."
  value       = try(azurerm_user_assigned_identity.data_compare[0].client_id, null)
}
