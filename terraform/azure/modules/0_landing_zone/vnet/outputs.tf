output "vnet_id" {
  description = "The ID of the Virtual Network"
  value = try(module.vnet[0].resource_id, null)
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value = try(module.vnet[0].name, null)
}

output "subnets" {
  description = "Map of subnet names to resource IDs"
  value = try(module.vnet[0].subnets, null)
}

output "resource_id" {
  value = try(module.vnet[0].resource_id, null)
}

