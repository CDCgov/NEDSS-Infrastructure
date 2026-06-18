output "private_dns_zone_id" { # TODO what is/could this used by?
  value = try(azurerm_private_dns_zone.private[0].id, "Module not enabled")
}
