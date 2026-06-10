output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.this.name
}

output "subnet" {
  description = "Full subnet resource"
  value       = azurerm_subnet.this
}
