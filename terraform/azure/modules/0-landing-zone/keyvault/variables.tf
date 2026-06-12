variable "enabled" {
  type        = bool
  description = "Enable or disable the entire module without removing it."
  default     = true
}

variable "name" {
  description = <<-EOT
    Name of the Key Vault. Must be globally unique across all of Azure.
    Constraints: 3-24 characters, alphanumeric and hyphens only,
    must start with a letter, and cannot end with a hyphen.
  EOT
  type        = string

  validation {
    condition = can(
      regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name)
    )
    error_message = <<-EOT
      Key Vault name must be 3-24 characters, start with a letter,
      end with a letter or digit, and contain only alphanumerics and hyphens.
    EOT
  }
}

variable "location" {
  description = "Azure region where the Key Vault will be created (e.g. 'eastus')."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy the Key Vault into."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "tenant_id" {
  description = <<-EOT
    Azure Active Directory tenant ID that owns the Key Vault.
    Defaults to the tenant of the currently authenticated client.
    Override when deploying into a tenant different from the one
    used for authentication.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.tenant_id == null || can(
      regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id)
    )
    error_message = "tenant_id must be a valid UUID (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)."
  }
}

variable "sku_name" {
  description = <<-EOT
    Pricing tier for the Key Vault.
    - "standard": software-protected keys, suitable for most workloads.
    - "premium":  adds HSM-backed keys for compliance or high-security use.
  EOT
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  description = <<-EOT
    Allow Azure Virtual Machines to retrieve certificates stored as
    secrets in this Key Vault during VM provisioning or extension runs.
  EOT
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = <<-EOT
    Allow Azure Disk Encryption to retrieve secrets and unwrap keys
    stored in this Key Vault for encrypting VM OS and data disks.
  EOT
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = <<-EOT
    Allow Azure Resource Manager template deployments to retrieve
    secrets from this Key Vault using the reference() function.
  EOT
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = <<-EOT
    When true (recommended), data-plane access is governed by Azure RBAC
    role assignments, replacing the legacy access-policy model.
    Set to false only when migrating existing vaults that rely on
    access policies and have not yet been converted to RBAC.
  EOT
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = <<-EOT
    Prevent permanent deletion of the vault and its objects until the
    soft-delete retention period expires. Once enabled this cannot be
    disabled. Strongly recommended for production workloads.
  EOT
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = <<-EOT
    Number of days soft-deleted vaults and their contents are retained
    before they can be purged. Accepted range: 7-90 days.
    Microsoft recommends 90 days for production environments.
  EOT
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90 (inclusive)."
  }
}

variable "public_network_access_enabled" {
  description = <<-EOT
    Allow access to the Key Vault over the public internet.
    Set to false when all access is routed through a private endpoint;
    leaving this true while using private endpoints permits both paths.
  EOT
  type        = bool
  default     = true
}

variable "firewall_ip_rules" {
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

  validation {
    condition = alltrue([
      for cidr in var.firewall_ip_rules :
      can(cidrhost(cidr, 0)) || can(cidrhost("${cidr}/32", 0))
    ])
    error_message = <<-EOT
      All entries in firewall_ip_rules must be valid IPv4 addresses
      (e.g. "203.0.113.10") or CIDR blocks (e.g. "198.51.100.0/24").
    EOT
  }
}

variable "firewall_virtual_network_subnet_ids" {
  description = <<-EOT
    List of subnet resource IDs granted access via VNet service
    endpoints. The subnets must have the
    "Microsoft.KeyVault" service endpoint enabled.
    Example: ["/subscriptions/.../subnets/app-subnet"]
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.firewall_virtual_network_subnet_ids :
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", id))
    ])
    error_message = <<-EOT
      Each entry must be a fully qualified subnet resource ID in the form:
      /subscriptions/{sub}/resourceGroups/{rg}/providers/
        Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}
    EOT
  }
}

variable "role_assignments" {
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

  validation {
    condition = alltrue([
      for k, v in var.role_assignments :
      v.principal_id != "" && v.role != ""
    ])
    error_message = "Each role assignment must provide a non-empty principal_id and role."
  }

  validation {
    condition = alltrue([
      for k, v in var.role_assignments :
      v.principal_type == null ||
      contains(["User", "Group", "ServicePrincipal", "Device"], v.principal_type)
    ])
    error_message = "principal_type must be one of: User, Group, ServicePrincipal, Device."
  }
}

variable "access_policies" {
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

  validation {
    condition = alltrue([
      for k, v in var.access_policies : length(trimspace(v.object_id)) > 0
    ])
    error_message = "Each access policy must provide a non-empty object_id."
  }
}

variable "contacts" {
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

  validation {
    condition = alltrue([
      for c in var.contacts :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", c.email))
    ])
    error_message = "Each contact must have a valid email address."
  }
}

variable "private_endpoint" {
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

variable "tags" {
  description = <<-EOT
    Map of tags applied to all resources created by this module.
    Use to enforce organisational tagging policies (e.g. cost centre,
    environment, owner).
    Example: { environment = "production", cost_centre = "platform" }
  EOT
  type        = map(string)
  default     = {}
}
