variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet" {
  description = "Subnet configuration"
  type = object({
    name             = string
    address_prefixes = list(string)

    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)

    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = list(string)
    })), [])

    service_endpoint_policy_ids = optional(list(string), [])

    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), [])
  })
}
