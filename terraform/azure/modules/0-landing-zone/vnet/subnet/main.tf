resource "azurerm_subnet" "this" {
  name                 = var.subnet.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet.address_prefixes

  private_endpoint_network_policies             = var.subnet.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.subnet.private_link_service_network_policies_enabled

  service_endpoints = length(var.subnet.service_endpoints_with_location) > 0 ? distinct([
    for ep in var.subnet.service_endpoints_with_location : ep.service
  ]) : []

  service_endpoint_policy_ids = var.subnet.service_endpoint_policy_ids

  dynamic "delegation" {
    for_each = var.subnet.delegations

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}
