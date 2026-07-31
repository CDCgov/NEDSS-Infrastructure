################################################################################
# Source: NEDSS-Infrastructure/terraform/azure/modules/0-landing-zone/keyvault/variables.tf
################################################################################
variable "keyvault_enabled" {
  type        = bool
  description = "Enable or disable the entire module without removing it."
  default     = true
}

variable "keyvault_tenant_id" {
  description = <<-EOT
    Azure Active Directory tenant ID that owns the Key Vault.
    Defaults to the tenant of the currently authenticated client.
    Override when deploying into a tenant different from the one
    used for authentication.
  EOT
  type        = string
  default     = null
}

variable "keyvault_sku_name" {
  description = <<-EOT
    Pricing tier for the Key Vault.
    - "standard": software-protected keys, suitable for most workloads.
    - "premium":  adds HSM-backed keys for compliance or high-security use.
  EOT
  type        = string
  default     = "standard"
}

variable "keyvault_enabled_for_deployment" {
  description = <<-EOT
    Allow Azure Virtual Machines to retrieve certificates stored as
    secrets in this Key Vault during VM provisioning or extension runs.
  EOT
  type        = bool
  default     = false
}

variable "keyvault_enabled_for_disk_encryption" {
  description = <<-EOT
    Allow Azure Disk Encryption to retrieve secrets and unwrap keys
    stored in this Key Vault for encrypting VM OS and data disks.
  EOT
  type        = bool
  default     = false
}

variable "keyvault_enabled_for_template_deployment" {
  description = <<-EOT
    Allow Azure Resource Manager template deployments to retrieve
    secrets from this Key Vault using the reference() function.
  EOT
  type        = bool
  default     = false
}

variable "keyvault_enable_rbac_authorization" {
  description = <<-EOT
    When true (recommended), data-plane access is governed by Azure RBAC
    role assignments, replacing the legacy access-policy model.
    Set to false only when migrating existing vaults that rely on
    access policies and have not yet been converted to RBAC.
  EOT
  type        = bool
  default     = true
}

variable "keyvault_purge_protection_enabled" {
  description = <<-EOT
    Prevent permanent deletion of the vault and its objects until the
    soft-delete retention period expires. Once enabled this cannot be
    disabled. Strongly recommended for production workloads.
  EOT
  type        = bool
  default     = true
}

variable "keyvault_soft_delete_retention_days" {
  description = <<-EOT
    Number of days soft-deleted vaults and their contents are retained
    before they can be purged. Accepted range: 7-90 days.
    Microsoft recommends 90 days for production environments.
  EOT
  type        = number
  default     = 90
}

variable "keyvault_public_network_access_enabled" {
  description = <<-EOT
    Allow access to the Key Vault over the public internet.
    Set to false when all access is routed through a private endpoint;
    leaving this true while using private endpoints permits both paths.
  EOT
  type        = bool
  default     = true
}

variable "keyvault_firewall_ip_rules" {
  description = <<-EOT
    List of IPv4 addresses or CIDR ranges allowed through the Key Vault
    firewall. Providing any entry sets the network ACL default action
    to "Deny" and bypass to "AzureServices", so only listed ranges and
    trusted Azure services can reach the vault.

    Examples: ["203.0.113.10/32", "198.51.100.0/24"]

    Note: "0.0.0.0/0" permits all public IPs and is not recommended
    for production environments.
  EOT
  type        = list(string)
  default     = []
}

variable "keyvault_firewall_virtual_network_subnet_ids" {
  description = <<-EOT
    List of subnet resource IDs granted access via VNet service
    endpoints. The subnets must have the
    "Microsoft.KeyVault" service endpoint enabled.
    Example: ["/subscriptions/.../subnets/app-subnet"]
  EOT
  type        = list(string)
  default     = []
}

variable "keyvault_role_assignments" {
  description = <<-EOT
    Map of Azure RBAC role assignments for the Key Vault data plane.
    Applies only when enable_rbac_authorization = true (the default).

    Map key: an arbitrary unique label used as the Terraform resource key.
    Map value fields:
    - principal_id:   (required) Object ID of the AAD user, group, or
                      service principal to assign the role to.
    - role:           (required) Built-in role name or full resource ID
                      of a custom role definition.
                      Common built-in roles:
                        "Key Vault Administrator"
                        "Key Vault Secrets Officer"
                        "Key Vault Secrets User"
                        "Key Vault Crypto Officer"
                        "Key Vault Crypto User"
                        "Key Vault Reader"
                        "Key Vault Certificate User"
    - principal_type: (optional) "User", "Group", "ServicePrincipal",
                      or "Device". Supplying this prevents an extra AAD
                      lookup and reduces apply time.
    - description:    (optional) Free-text note stored on the assignment
                      for auditing purposes.
  EOT
  type = map(object({
    principal_id   = string
    role           = string
    principal_type = optional(string)
    description    = optional(string)
  }))
  default = {}
}

variable "keyvault_access_policies" {
  description = <<-EOT
    Map of legacy access policies. Applies only when
    enable_rbac_authorization = false.
    Prefer RBAC for new deployments; use this only to support existing
    vaults that have not been migrated.

    Map key: an arbitrary unique label.
    Map value fields:
    - object_id:               (required) AAD object ID of the principal.
    - tenant_id:               (optional) Tenant ID; defaults to
                               var.tenant_id or the current tenant.
    - key_permissions:         (optional) Permitted key operations.
    - secret_permissions:      (optional) Permitted secret operations.
    - certificate_permissions: (optional) Permitted certificate ops.
    - storage_permissions:     (optional) Permitted storage account ops.
  EOT
  type = map(object({
    object_id               = string
    tenant_id               = optional(string)
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = {}
}

variable "keyvault_contacts" {
  description = <<-EOT
    List of certificate contacts notified on certificate lifecycle events
    (e.g. expiry, auto-renewal failures). At least an email is required;
    name and phone are optional.
  EOT
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}

variable "keyvault_private_endpoint" {
  description = <<-EOT
    Optional configuration for a Private Endpoint that places the Key
    Vault on a VNet, removing the need for public internet access.
    When provided, consider setting public_network_access_enabled = false.

    Fields:
    - subnet_id:            (required) Resource ID of the target subnet.
                            The subnet must not have a network policy
                            that blocks private endpoints.
    - name:                 (optional) Name for the endpoint resource;
                            defaults to "<vault-name>-pe".
    - connection_name:      (optional) Name for the private service
                            connection; defaults to "<vault-name>-psc".
    - private_dns_zone_ids: (optional) List of private DNS zone resource
                            IDs to register the endpoint in, typically
                            ["...privatelink.vaultcore.azure.net"].
  EOT
  type = object({
    subnet_id            = string
    name                 = optional(string)
    connection_name      = optional(string)
    private_dns_zone_ids = optional(list(string), [])
  })
  default = null
}

variable "keyvault_tags" {
  description = <<-EOT
    Map of tags applied to all resources created by this module.
    Use to enforce organisational tagging policies (e.g. cost centre,
    environment, owner).
    Example: { environment = "production", cost_centre = "platform" }
  EOT
  type        = map(string)
  default     = {}
}


################################################################################
# Source: NEDSS-Infrastructure/terraform/azure/modules/0-landing-zone/vnet/variables.tf
################################################################################

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id."
}

variable "vnet_enabled" {
  type        = bool
  description = "Whether to create the vnet"
  default     = true
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

variable "vnet_resource_group_name" {
  type        = string
  description = "The name of the existing resource group"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

variable "vnet_subnets" {
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


################################################################################
# Source: NEDSS-Infrastructure/terraform/azure/modules/0-landing-zone/private-dns-zone/variables.tf
################################################################################
variable "private_dns_zone_enabled" {
  type        = bool
  description = "Whether to have Terraform provision the resources from this module in your Azure subscription"
  default     = true # If this is false then all the other variables below are ignored
}

# Note that if "enabled" is true then a non-empty value must be specified for "resource_group_name" and also for "private_dns_zone_name", otherwise `terraform plan` will fail (because those variables are used by resources for args which do not allow an empty string).

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = ""
}

variable "private_domain_name" {
  type        = string
  description = "The name of the Private DNS zone (if one is to be provisioned by Terraform)"
  default     = ""
}

variable "private_dns_zone_dns_records" {
  description = "A map of DNS records to create in the private dns zone. Only provide this if the 'enabled' variable is set to true."
  type = map(object({
    record_name  = string
    record_type  = string
    ttl          = optional(number, 300)
    records      = optional(list(string))
    cname_record = optional(string)
  }))
  default = {}
}

variable "private_dns_zone_registration_enabled" {
  description = "Whether auto registration is enabled"
  type        = bool
  default     = false
}


################################################################################
# Source: NEDSS-Infrastructure/terraform/azure/modules/0-landing-zone/public-dns-zone/variables.tf
################################################################################
variable "public_dns_zone_enabled" {
  type        = bool
  description = "Whether to have Terraform provision the resources from this module in your Azure subscription"
  default     = true
}

variable "public_domain_name" {
  type        = string
  description = "The root domain (e.g., example.com)"
  default     = ""
}

variable "public_dns_zone_dns_records" {
  description = "A map of DNS records to create"
  type = map(object({
    record_name  = string
    record_type  = string
    ttl          = optional(number, 300)
    records      = optional(list(string))
    cname_record = optional(string)
  }))
  default = {}
}

variable "subnet__public_gateways__address_prefixes" {
  type = list(string)
}

variable "subnet__aks__address_prefixes" {
  type = list(string)
}

variable "subnet__hdikafka__address_prefixes" {
  type = list(string)
}

variable "subnet__endpoint__address_prefixes" {
  type = list(string)
}
