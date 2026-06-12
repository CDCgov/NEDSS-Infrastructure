<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Map of legacy access policies. Applies only when<br/>enable\_rbac\_authorization = false.<br/>Prefer RBAC for new deployments; use this only to support existing<br/>vaults that have not been migrated.<br/><br/>Map key: an arbitrary unique label.<br/>Map value fields:<br/>- object\_id:               (required) AAD object ID of the principal.<br/>- tenant\_id:               (optional) Tenant ID; defaults to<br/>                           var.tenant\_id or the current tenant.<br/>- key\_permissions:         (optional) Permitted key operations.<br/>- secret\_permissions:      (optional) Permitted secret operations.<br/>- certificate\_permissions: (optional) Permitted certificate ops.<br/>- storage\_permissions:     (optional) Permitted storage account ops. | <pre>map(object({<br/>    object_id               = string<br/>    tenant_id               = optional(string)<br/>    key_permissions         = optional(list(string), [])<br/>    secret_permissions      = optional(list(string), [])<br/>    certificate_permissions = optional(list(string), [])<br/>    storage_permissions     = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | List of certificate contacts notified on certificate lifecycle events<br/>(e.g. expiry, auto-renewal failures). At least an email is required;<br/>name and phone are optional. | <pre>list(object({<br/>    email = string<br/>    name  = optional(string)<br/>    phone = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | When true (recommended), data-plane access is governed by Azure RBAC<br/>role assignments, replacing the legacy access-policy model.<br/>Set to false only when migrating existing vaults that rely on<br/>access policies and have not yet been converted to RBAC. | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable or disable the entire module without removing it. | `bool` | `true` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Allow Azure Virtual Machines to retrieve certificates stored as<br/>secrets in this Key Vault during VM provisioning or extension runs. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Allow Azure Disk Encryption to retrieve secrets and unwrap keys<br/>stored in this Key Vault for encrypting VM OS and data disks. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Allow Azure Resource Manager template deployments to retrieve<br/>secrets from this Key Vault using the reference() function. | `bool` | `false` | no |
| <a name="input_firewall_ip_rules"></a> [firewall\_ip\_rules](#input\_firewall\_ip\_rules) | List of IPv4 addresses or CIDR ranges allowed through the Key Vault<br/>firewall. Providing any entry sets the network ACL default action<br/>to "Deny" and bypass to "AzureServices", so only listed ranges and<br/>trusted Azure services can reach the vault.<br/><br/>Examples: ["203.0.113.10/32", "198.51.100.0/24"]<br/><br/>Note: "0.0.0.0/0" permits all public IPs and is not recommended<br/>for production environments. | `list(string)` | `[]` | no |
| <a name="input_firewall_virtual_network_subnet_ids"></a> [firewall\_virtual\_network\_subnet\_ids](#input\_firewall\_virtual\_network\_subnet\_ids) | List of subnet resource IDs granted access via VNet service<br/>endpoints. The subnets must have the<br/>"Microsoft.KeyVault" service endpoint enabled.<br/>Example: ["/subscriptions/.../subnets/app-subnet"] | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the Key Vault will be created (e.g. 'eastus'). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Key Vault. Must be globally unique across all of Azure.<br/>Constraints: 3-24 characters, alphanumeric and hyphens only,<br/>must start with a letter, and cannot end with a hyphen. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Optional configuration for a Private Endpoint that places the Key<br/>Vault on a VNet, removing the need for public internet access.<br/>When provided, consider setting public\_network\_access\_enabled = false.<br/><br/>Fields:<br/>- subnet\_id:            (required) Resource ID of the target subnet.<br/>                        The subnet must not have a network policy<br/>                        that blocks private endpoints.<br/>- name:                 (optional) Name for the endpoint resource;<br/>                        defaults to "<vault-name>-pe".<br/>- connection\_name:      (optional) Name for the private service<br/>                        connection; defaults to "<vault-name>-psc".<br/>- private\_dns\_zone\_ids: (optional) List of private DNS zone resource<br/>                        IDs to register the endpoint in, typically<br/>                        ["...privatelink.vaultcore.azure.net"]. | <pre>object({<br/>    subnet_id            = string<br/>    name                 = optional(string)<br/>    connection_name      = optional(string)<br/>    private_dns_zone_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow access to the Key Vault over the public internet.<br/>Set to false when all access is routed through a private endpoint;<br/>leaving this true while using private endpoints permits both paths. | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Prevent permanent deletion of the vault and its objects until the<br/>soft-delete retention period expires. Once enabled this cannot be<br/>disabled. Strongly recommended for production workloads. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to deploy the Key Vault into. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Map of Azure RBAC role assignments for the Key Vault data plane.<br/>Applies only when enable\_rbac\_authorization = true (the default).<br/><br/>Map key: an arbitrary unique label used as the Terraform resource key.<br/>Map value fields:<br/>- principal\_id:   (required) Object ID of the AAD user, group, or<br/>                  service principal to assign the role to.<br/>- role:           (required) Built-in role name or full resource ID<br/>                  of a custom role definition.<br/>                  Common built-in roles:<br/>                    "Key Vault Administrator"<br/>                    "Key Vault Secrets Officer"<br/>                    "Key Vault Secrets User"<br/>                    "Key Vault Crypto Officer"<br/>                    "Key Vault Crypto User"<br/>                    "Key Vault Reader"<br/>                    "Key Vault Certificate User"<br/>- principal\_type: (optional) "User", "Group", "ServicePrincipal",<br/>                  or "Device". Supplying this prevents an extra AAD<br/>                  lookup and reduces apply time.<br/>- description:    (optional) Free-text note stored on the assignment<br/>                  for auditing purposes. | <pre>map(object({<br/>    principal_id   = string<br/>    role           = string<br/>    principal_type = optional(string)<br/>    description    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Pricing tier for the Key Vault.<br/>- "standard": software-protected keys, suitable for most workloads.<br/>- "premium":  adds HSM-backed keys for compliance or high-security use. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Number of days soft-deleted vaults and their contents are retained<br/>before they can be purged. Accepted range: 7-90 days.<br/>Microsoft recommends 90 days for production environments. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags applied to all resources created by this module.<br/>Use to enforce organisational tagging policies (e.g. cost centre,<br/>environment, owner).<br/>Example: { environment = "production", cost\_centre = "platform" } | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure Active Directory tenant ID that owns the Key Vault.<br/>Defaults to the tenant of the currently authenticated client.<br/>Override when deploying into a tenant different from the one<br/>used for authentication. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Key Vault. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Key Vault. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the private endpoint, if created. |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | Private IP address of the private endpoint, if created. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID the Key Vault belongs to. |
| <a name="output_uri"></a> [uri](#output\_uri) | URI of the Key Vault (used to access vault objects). |
<!-- END_TF_DOCS -->