output "id" {
  description = "Resource ID of the Key Vault."
  value       = try(azurerm_key_vault.this[0].id, "Module not enabled")
}

output "name" {
  description = "Name of the Key Vault."
  value       = try(azurerm_key_vault.this[0].name, "Module not enabled")
}

output "uri" {
  description = "URI of the Key Vault (used to access vault objects)."
  value       = try(azurerm_key_vault.this[0].vault_uri, "Module not enabled")
}

output "tenant_id" {
  description = "Tenant ID the Key Vault belongs to."
  value       = try(azurerm_key_vault.this[0].tenant_id, "Module not enabled")
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_ip" {
  description = "Private IP address of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address, null)
}
