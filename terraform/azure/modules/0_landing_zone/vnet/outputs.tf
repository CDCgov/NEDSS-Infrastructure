output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.vnet.name
}

output "subnets" {
  description = "Map of subnet names to resource IDs"
  value       = module.vnet.subnets
}

output "resource_id" {
  value = module.vnet.resource_id
}