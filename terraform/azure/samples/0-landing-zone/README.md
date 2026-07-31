# CDCgov GitHub Organization Open Source Project Template

**Template for clearance: This project serves as a template to aid projects in starting up and moving through clearance procedures. To start, create a new repository and implement the required [open practices](open_practices.md), train on and agree to adhere to the organization's [rules of behavior](rules_of_behavior.md), and [send a request through the create repo form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) using language from this template as a Guide.**

**General disclaimer** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/organization/mission.htm).  GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise. 

## Access Request, Repo Creation Request

* [CDC GitHub Open Project Request Form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) _[Requires a CDC Office365 login, if you do not have a CDC Office365 please ask a friend who does to submit the request on your behalf. If you're looking for access to the CDCEnt private organization, please use the [GitHub Enterprise Cloud Access Request form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUQjVJVDlKS1c0SlhQSUxLNVBaOEZCNUczVS4u).]_

## Related documents

* [Open Practices](open_practices.md)
* [Rules of Behavior](rules_of_behavior.md)
* [Thanks and Acknowledgements](thanks.md)
* [Disclaimer](DISCLAIMER.md)
* [Contribution Notice](CONTRIBUTING.md)
* [Code of Conduct](code-of-conduct.md)

## Overview

Infrastructure required by the NEDSS application is contained within. Currently, the main method of deployment is Terraform which have been split out into modules.
  
## Public Domain Standard Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice
The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices
Please refer to [CDC's Template Repository](https://github.com/CDCgov/template)
for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md),
[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md),
and [code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_keyvault"></a> [keyvault](#module\_keyvault) | ../../modules/0-landing-zone/keyvault | n/a |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | ../../modules/0-landing-zone/private-dns-zone | n/a |
| <a name="module_public_dns"></a> [public\_dns](#module\_public\_dns) | ../../modules/0-landing-zone/public-dns-zone | n/a |
| <a name="module_subnet"></a> [subnet](#module\_subnet) | ../../modules/0-landing-zone/vnet/subnet | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/0-landing-zone/vnet | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_keyvault_access_policies"></a> [keyvault\_access\_policies](#input\_keyvault\_access\_policies) | Map of legacy access policies. Applies only when<br/>enable\_rbac\_authorization = false.<br/>Prefer RBAC for new deployments; use this only to support existing<br/>vaults that have not been migrated.<br/><br/>Map key: an arbitrary unique label.<br/>Map value fields:<br/>- object\_id:               (required) AAD object ID of the principal.<br/>- tenant\_id:               (optional) Tenant ID; defaults to<br/>                           var.tenant\_id or the current tenant.<br/>- key\_permissions:         (optional) Permitted key operations.<br/>- secret\_permissions:      (optional) Permitted secret operations.<br/>- certificate\_permissions: (optional) Permitted certificate ops.<br/>- storage\_permissions:     (optional) Permitted storage account ops. | <pre>map(object({<br/>    object_id               = string<br/>    tenant_id               = optional(string)<br/>    key_permissions         = optional(list(string), [])<br/>    secret_permissions      = optional(list(string), [])<br/>    certificate_permissions = optional(list(string), [])<br/>    storage_permissions     = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_keyvault_contacts"></a> [keyvault\_contacts](#input\_keyvault\_contacts) | List of certificate contacts notified on certificate lifecycle events<br/>(e.g. expiry, auto-renewal failures). At least an email is required;<br/>name and phone are optional. | <pre>list(object({<br/>    email = string<br/>    name  = optional(string)<br/>    phone = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_keyvault_enable_rbac_authorization"></a> [keyvault\_enable\_rbac\_authorization](#input\_keyvault\_enable\_rbac\_authorization) | When true (recommended), data-plane access is governed by Azure RBAC<br/>role assignments, replacing the legacy access-policy model.<br/>Set to false only when migrating existing vaults that rely on<br/>access policies and have not yet been converted to RBAC. | `bool` | `true` | no |
| <a name="input_keyvault_enabled"></a> [keyvault\_enabled](#input\_keyvault\_enabled) | Enable or disable the entire module without removing it. | `bool` | `true` | no |
| <a name="input_keyvault_enabled_for_deployment"></a> [keyvault\_enabled\_for\_deployment](#input\_keyvault\_enabled\_for\_deployment) | Allow Azure Virtual Machines to retrieve certificates stored as<br/>secrets in this Key Vault during VM provisioning or extension runs. | `bool` | `false` | no |
| <a name="input_keyvault_enabled_for_disk_encryption"></a> [keyvault\_enabled\_for\_disk\_encryption](#input\_keyvault\_enabled\_for\_disk\_encryption) | Allow Azure Disk Encryption to retrieve secrets and unwrap keys<br/>stored in this Key Vault for encrypting VM OS and data disks. | `bool` | `false` | no |
| <a name="input_keyvault_enabled_for_template_deployment"></a> [keyvault\_enabled\_for\_template\_deployment](#input\_keyvault\_enabled\_for\_template\_deployment) | Allow Azure Resource Manager template deployments to retrieve<br/>secrets from this Key Vault using the reference() function. | `bool` | `false` | no |
| <a name="input_keyvault_firewall_ip_rules"></a> [keyvault\_firewall\_ip\_rules](#input\_keyvault\_firewall\_ip\_rules) | List of IPv4 addresses or CIDR ranges allowed through the Key Vault<br/>firewall. Providing any entry sets the network ACL default action<br/>to "Deny" and bypass to "AzureServices", so only listed ranges and<br/>trusted Azure services can reach the vault.<br/><br/>Examples: ["203.0.113.10/32", "198.51.100.0/24"]<br/><br/>Note: "0.0.0.0/0" permits all public IPs and is not recommended<br/>for production environments. | `list(string)` | `[]` | no |
| <a name="input_keyvault_firewall_virtual_network_subnet_ids"></a> [keyvault\_firewall\_virtual\_network\_subnet\_ids](#input\_keyvault\_firewall\_virtual\_network\_subnet\_ids) | List of subnet resource IDs granted access via VNet service<br/>endpoints. The subnets must have the<br/>"Microsoft.KeyVault" service endpoint enabled.<br/>Example: ["/subscriptions/.../subnets/app-subnet"] | `list(string)` | `[]` | no |
| <a name="input_keyvault_private_endpoint"></a> [keyvault\_private\_endpoint](#input\_keyvault\_private\_endpoint) | Optional configuration for a Private Endpoint that places the Key<br/>Vault on a VNet, removing the need for public internet access.<br/>When provided, consider setting public\_network\_access\_enabled = false.<br/><br/>Fields:<br/>- subnet\_id:            (required) Resource ID of the target subnet.<br/>                        The subnet must not have a network policy<br/>                        that blocks private endpoints.<br/>- name:                 (optional) Name for the endpoint resource;<br/>                        defaults to "<vault-name>-pe".<br/>- connection\_name:      (optional) Name for the private service<br/>                        connection; defaults to "<vault-name>-psc".<br/>- private\_dns\_zone\_ids: (optional) List of private DNS zone resource<br/>                        IDs to register the endpoint in, typically<br/>                        ["...privatelink.vaultcore.azure.net"]. | <pre>object({<br/>    subnet_id            = string<br/>    name                 = optional(string)<br/>    connection_name      = optional(string)<br/>    private_dns_zone_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_keyvault_public_network_access_enabled"></a> [keyvault\_public\_network\_access\_enabled](#input\_keyvault\_public\_network\_access\_enabled) | Allow access to the Key Vault over the public internet.<br/>Set to false when all access is routed through a private endpoint;<br/>leaving this true while using private endpoints permits both paths. | `bool` | `true` | no |
| <a name="input_keyvault_purge_protection_enabled"></a> [keyvault\_purge\_protection\_enabled](#input\_keyvault\_purge\_protection\_enabled) | Prevent permanent deletion of the vault and its objects until the<br/>soft-delete retention period expires. Once enabled this cannot be<br/>disabled. Strongly recommended for production workloads. | `bool` | `true` | no |
| <a name="input_keyvault_role_assignments"></a> [keyvault\_role\_assignments](#input\_keyvault\_role\_assignments) | Map of Azure RBAC role assignments for the Key Vault data plane.<br/>Applies only when enable\_rbac\_authorization = true (the default).<br/><br/>Map key: an arbitrary unique label used as the Terraform resource key.<br/>Map value fields:<br/>- principal\_id:   (required) Object ID of the AAD user, group, or<br/>                  service principal to assign the role to.<br/>- role:           (required) Built-in role name or full resource ID<br/>                  of a custom role definition.<br/>                  Common built-in roles:<br/>                    "Key Vault Administrator"<br/>                    "Key Vault Secrets Officer"<br/>                    "Key Vault Secrets User"<br/>                    "Key Vault Crypto Officer"<br/>                    "Key Vault Crypto User"<br/>                    "Key Vault Reader"<br/>                    "Key Vault Certificate User"<br/>- principal\_type: (optional) "User", "Group", "ServicePrincipal",<br/>                  or "Device". Supplying this prevents an extra AAD<br/>                  lookup and reduces apply time.<br/>- description:    (optional) Free-text note stored on the assignment<br/>                  for auditing purposes. | <pre>map(object({<br/>    principal_id   = string<br/>    role           = string<br/>    principal_type = optional(string)<br/>    description    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_keyvault_sku_name"></a> [keyvault\_sku\_name](#input\_keyvault\_sku\_name) | Pricing tier for the Key Vault.<br/>- "standard": software-protected keys, suitable for most workloads.<br/>- "premium":  adds HSM-backed keys for compliance or high-security use. | `string` | `"standard"` | no |
| <a name="input_keyvault_soft_delete_retention_days"></a> [keyvault\_soft\_delete\_retention\_days](#input\_keyvault\_soft\_delete\_retention\_days) | Number of days soft-deleted vaults and their contents are retained<br/>before they can be purged. Accepted range: 7-90 days.<br/>Microsoft recommends 90 days for production environments. | `number` | `90` | no |
| <a name="input_keyvault_tags"></a> [keyvault\_tags](#input\_keyvault\_tags) | Map of tags applied to all resources created by this module.<br/>Use to enforce organisational tagging policies (e.g. cost centre,<br/>environment, owner).<br/>Example: { environment = "production", cost\_centre = "platform" } | `map(string)` | `{}` | no |
| <a name="input_keyvault_tenant_id"></a> [keyvault\_tenant\_id](#input\_keyvault\_tenant\_id) | Azure Active Directory tenant ID that owns the Key Vault.<br/>Defaults to the tenant of the currently authenticated client.<br/>Override when deploying into a tenant different from the one<br/>used for authentication. | `string` | `null` | no |
| <a name="input_private_dns_zone_dns_records"></a> [private\_dns\_zone\_dns\_records](#input\_private\_dns\_zone\_dns\_records) | A map of DNS records to create in the private dns zone. Only provide this if the 'enabled' variable is set to true. | <pre>map(object({<br/>    record_name  = string<br/>    record_type  = string<br/>    ttl          = optional(number, 300)<br/>    records      = optional(list(string))<br/>    cname_record = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_private_dns_zone_enabled"></a> [private\_dns\_zone\_enabled](#input\_private\_dns\_zone\_enabled) | Whether to have Terraform provision the resources from this module in your Azure subscription | `bool` | `true` | no |
| <a name="input_private_dns_zone_registration_enabled"></a> [private\_dns\_zone\_registration\_enabled](#input\_private\_dns\_zone\_registration\_enabled) | Whether auto registration is enabled | `bool` | `false` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | The name of the resource group | `string` | `""` | no |
| <a name="input_private_domain_name"></a> [private\_domain\_name](#input\_private\_domain\_name) | The name of the Private DNS zone (if one is to be provisioned by Terraform) | `string` | `""` | no |
| <a name="input_public_dns_zone_dns_records"></a> [public\_dns\_zone\_dns\_records](#input\_public\_dns\_zone\_dns\_records) | A map of DNS records to create | <pre>map(object({<br/>    record_name  = string<br/>    record_type  = string<br/>    ttl          = optional(number, 300)<br/>    records      = optional(list(string))<br/>    cname_record = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_public_dns_zone_enabled"></a> [public\_dns\_zone\_enabled](#input\_public\_dns\_zone\_enabled) | Whether to have Terraform provision the resources from this module in your Azure subscription | `bool` | `true` | no |
| <a name="input_public_domain_name"></a> [public\_domain\_name](#input\_public\_domain\_name) | The root domain (e.g., example.com) | `string` | `""` | no |
| <a name="input_subnet__aks__address_prefixes"></a> [subnet\_\_aks\_\_address\_prefixes](#input\_subnet\_\_aks\_\_address\_prefixes) | n/a | `list(string)` | n/a | yes |
| <a name="input_subnet__endpoint__address_prefixes"></a> [subnet\_\_endpoint\_\_address\_prefixes](#input\_subnet\_\_endpoint\_\_address\_prefixes) | n/a | `list(string)` | n/a | yes |
| <a name="input_subnet__hdikafka__address_prefixes"></a> [subnet\_\_hdikafka\_\_address\_prefixes](#input\_subnet\_\_hdikafka\_\_address\_prefixes) | n/a | `list(string)` | n/a | yes |
| <a name="input_subnet__public_gateways__address_prefixes"></a> [subnet\_\_public\_gateways\_\_address\_prefixes](#input\_subnet\_\_public\_gateways\_\_address\_prefixes) | n/a | `list(string)` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription id. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the VNet | `list(string)` | n/a | yes |
| <a name="input_vnet_enabled"></a> [vnet\_enabled](#input\_vnet\_enabled) | Whether to create the vnet | `bool` | `true` | no |
| <a name="input_vnet_location"></a> [vnet\_location](#input\_vnet\_location) | The Azure region | `string` | `"eastus"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vnet | `string` | `"nbs"` | no |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the existing resource group | `string` | n/a | yes |
| <a name="input_vnet_subnets"></a> [vnet\_subnets](#input\_vnet\_subnets) | (Optional) A map of subnets to create<br/><br/> - `address_prefixes` - (Optional) The address prefixes to use for the subnet. One of `address_prefix`, `address_prefixes`, or `ipam_pools` must be specified.<br/> - `ipam_pools` - (Optional) IPAM pools to allocate address space from. When specified, the subnet will request address space from these pools. Each pool configuration supports:<br/>   - `pool_id`: Resource ID of the IPAM pool to allocate from<br/>   - `prefix_length`: The CIDR prefix length for this subnet (e.g., 24 for /24, 26 for /26)<br/>   - `allocation_type`: Type of allocation - "Static" (default) or "Dynamic"<br/> - `enforce_private_link_endpoint_network_policies` -<br/> - `enforce_private_link_service_network_policies` -<br/> - `name` - (Required) The name of the subnet. Changing this forces a new resource to be created.<br/> - `default_outbound_access_enabled` - (Optional) Whether to allow internet access from the subnet. Defaults to `false`.<br/> - `private_endpoint_network_policies` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Enabled`.<br/> - `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will **Enable** the policy and setting this to `false` will **Disable** the policy. Defaults to `true`.<br/> - `service_endpoint_policies` - (Optional) The map of objects with IDs of Service Endpoint Policies to associate with the subnet.<br/> - `service_endpoints_with_location` - (Optional) Service endpoints with location restrictions to associate with the subnet. Each service endpoint is an object with the following properties:<br/>   - `service` - (Required) The service name. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage`, `Microsoft.Storage.Global` and `Microsoft.Web`.<br/>   - `locations` - (Optional) A set of Azure region names where the service endpoint should apply. Default is `["*"]` to apply to all regions.<br/><br/> ---<br/> `delegation` (This setting is deprecated, use `delegations` instead) supports the following:<br/> - `name` - (Required) A name for this delegation.<br/>  - `service_delegation` - (Required) The service delegation to associate with the subnet. This is an object with a `name` property that specifies the name of the service delegation.<br/><br/>`delegations` supports the following:<br/> - `name` - (Required) A name for this delegation.<br/>  - `service_delegation` - (Required) The service delegation to associate with the subnet. This is an object with a `name` property that specifies the name of the service delegation.<br/><br/> ---<br/> `nat_gateway` supports the following:<br/> - `id` - (Optional) The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.<br/><br/> ---<br/> `network_security_group` supports the following:<br/> - `id` - (Optional) The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.<br/><br/> ---<br/> `route_table` supports the following:<br/> - `id` - (Optional) The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.<br/><br/> ---<br/> `timeouts` (Optional) supports the following:<br/> - `create` - (Defaults to 30 minutes) Used when creating the Subnet.<br/> - `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.<br/> - `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.<br/> - `update` - (Defaults to 30 minutes) Used when updating the Subnet.<br/><br/>---<br/>  `retry` (optional) supports the following:<br/>  - `error_message_regex` - (Optional) A list of regular expressions to match against the error message returned by the API. If any of these match, the retry will be triggered.<br/>  - `interval_seconds` - (Optional) The number of seconds to wait between retries. Defaults to 10.<br/>  - `max_interval_seconds` - (Optional) The maximum number of seconds to wait between retries. Defaults to 180.<br/><br/> ---<br/> `role_assignments` supports the following:<br/> - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.<br/> - `principal_id` - The ID of the principal to assign the role to.<br/> - `description` - (Optional) The description of the role assignment.<br/> - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.<br/> - `condition` - (Optional) The condition which will be used to scope the role assignment.<br/> - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.<br/> - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.<br/> - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute. | <pre>map(object({<br/>    address_prefixes = optional(list(string))<br/>    name             = string<br/>    ipam_pools = optional(list(object({<br/>      pool_id         = string<br/>      prefix_length   = optional(number)<br/>      allocation_type = optional(string, "Static")<br/>    })))<br/>    nat_gateway = optional(object({<br/>      id = string<br/>    }))<br/>    network_security_group = optional(object({<br/>      id = string<br/>    }))<br/>    private_endpoint_network_policies             = optional(string, "Enabled")<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>    route_table = optional(object({<br/>      id = string<br/>    }))<br/>    service_endpoint_policies = optional(map(object({<br/>      id = string<br/>    })))<br/>    service_endpoints_with_location = optional(list(object({<br/>      service   = string<br/>      locations = optional(list(string), ["*"])<br/>    })))<br/>    default_outbound_access_enabled = optional(bool, false)<br/>    sharing_scope                   = optional(string, null)<br/>    delegations = optional(list(object({<br/>      name = string<br/>      service_delegation = object({<br/>        name = string<br/>      })<br/>    })))<br/>    timeouts = optional(object({<br/>      create = optional(string, "30m")<br/>      read   = optional(string, "5m")<br/>      update = optional(string, "30m")<br/>      delete = optional(string, "30m")<br/>    }), {})<br/>    retry = optional(object({<br/>      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])<br/>      interval_seconds     = optional(number, 10)<br/>      max_interval_seconds = optional(number, 180)<br/>    }), {})<br/>    role_assignments = optional(map(object({<br/>      role_definition_id_or_name             = string<br/>      principal_id                           = string<br/>      description                            = optional(string, null)<br/>      skip_service_principal_aad_check       = optional(bool, false)<br/>      condition                              = optional(string, null)<br/>      condition_version                      = optional(string, null)<br/>      delegated_managed_identity_resource_id = optional(string, null)<br/>      principal_type                         = optional(string, null)<br/>    })))<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->