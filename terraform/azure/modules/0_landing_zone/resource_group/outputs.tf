output "id" {
  description = "Resource group ID"
  value       = try(azurerm_resource_group.this[0].id, null)
}

output "name" {
  description = "Resource group name"
  value       = try(azurerm_resource_group.this[0].name, null)
}

output "location" {
  description = "Resource group location"
  value       = try(azurerm_resource_group.this[0].location, null)
}