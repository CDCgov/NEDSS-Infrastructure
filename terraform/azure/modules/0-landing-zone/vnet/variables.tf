variable "enabled" {
  type        = bool
  description = "Whether to create the vnet"
  default     = true
}

variable "parent_id" {
  type        = string
  description = "The ID of the existing resource group where the VNet will be provisioned"
  # Retrieve this value by in the Azure portal going to the "Resource groups" service, click the name of the Resource group you
  # are specifying for 'vnet_resource_group_name', click 'JSON View', and use the value of the "id" field for this variable.
}

variable "vnet_location" {
  type        = string
  description = "The Azure region"
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  description = "Name of the vnet"
  default     = "nbs"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

variable "subnets" {
  type = map(object({
    address_prefixes = optional(list(string))
    name             = string
    ipam_pools = optional(list(object({
      pool_id         = string
      prefix_length   = optional(number)
      allocation_type = optional(string, "Static")
    })))
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = optional(list(string), ["*"])
    })))
    default_outbound_access_enabled = optional(bool, false)
    sharing_scope                   = optional(string, null)
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }), {})
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
    }), {})
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of subnets to create

 - `address_prefixes` - (Optional) The address prefixes to use for the subnet. One of `address_prefix`, `address_prefixes`, or `ipam_pools` must be specified.
 - `ipam_pools` - (Optional) IPAM pools to allocate address space from. When specified, the subnet will request address space from these pools. Each pool configuration supports:
   - `pool_id`: Resource ID of the IPAM pool to allocate from
   - `prefix_length`: The CIDR prefix length for this subnet (e.g., 24 for /24, 26 for /26)
   - `allocation_type`: Type of allocation - "Static" (default) or "Dynamic"
 - `enforce_private_link_endpoint_network_policies` -
 - `enforce_private_link_service_network_policies` -
 - `name` - (Required) The name of the subnet. Changing this forces a new resource to be created.
 - `default_outbound_access_enabled` - (Optional) Whether to allow internet access from the subnet. Defaults to `false`.
 - `private_endpoint_network_policies` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Enabled`.
 - `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will **Enable** the policy and setting this to `false` will **Disable** the policy. Defaults to `true`.
 - `service_endpoint_policies` - (Optional) The map of objects with IDs of Service Endpoint Policies to associate with the subnet.
 - `service_endpoints_with_location` - (Optional) Service endpoints with location restrictions to associate with the subnet. Each service endpoint is an object with the following properties:
   - `service` - (Required) The service name. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage`, `Microsoft.Storage.Global` and `Microsoft.Web`.
   - `locations` - (Optional) A set of Azure region names where the service endpoint should apply. Default is `["*"]` to apply to all regions.

 ---
 `delegation` (This setting is deprecated, use `delegations` instead) supports the following:
 - `name` - (Required) A name for this delegation.
  - `service_delegation` - (Required) The service delegation to associate with the subnet. This is an object with a `name` property that specifies the name of the service delegation.

`delegations` supports the following:
 - `name` - (Required) A name for this delegation.
  - `service_delegation` - (Required) The service delegation to associate with the subnet. This is an object with a `name` property that specifies the name of the service delegation.

 ---
 `nat_gateway` supports the following:
 - `id` - (Optional) The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.

 ---
 `network_security_group` supports the following:
 - `id` - (Optional) The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `route_table` supports the following:
 - `id` - (Optional) The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `timeouts` (Optional) supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Subnet.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
 - `update` - (Defaults to 30 minutes) Used when updating the Subnet.

---
  `retry` (optional) supports the following:
  - `error_message_regex` - (Optional) A list of regular expressions to match against the error message returned by the API. If any of these match, the retry will be triggered.
  - `interval_seconds` - (Optional) The number of seconds to wait between retries. Defaults to 10.
  - `max_interval_seconds` - (Optional) The maximum number of seconds to wait between retries. Defaults to 180.

 ---
 `role_assignments` supports the following:
 - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
 - `principal_id` - The ID of the principal to assign the role to.
 - `description` - (Optional) The description of the role assignment.
 - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
 - `condition` - (Optional) The condition which will be used to scope the role assignment.
 - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
 - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
 - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

DESCRIPTION

}
