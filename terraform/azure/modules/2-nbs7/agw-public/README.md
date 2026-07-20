<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |

## Providers

| Name                                                         | Version      |
| ------------------------------------------------------------ | ------------ |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=4.68, <5.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                  | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_application_gateway.agw_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway)                                                         | resource    |
| [azurerm_key_vault_access_policy.agw_mi_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)                                              | resource    |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                                          | resource    |
| [azurerm_network_security_rule.allow_agw_frontend_traffic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                     | resource    |
| [azurerm_network_security_rule.allow_gateway_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                          | resource    |
| [azurerm_public_ip.agw_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)                                                                          | resource    |
| [azurerm_role_assignment.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                        | resource    |
| [azurerm_subnet_network_security_group_association.nsg_subnet_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource    |
| [azurerm_user_assigned_identity.agw_mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)                                                       | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                                                     | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)                                                                           | data source |
| [azurerm_key_vault_secret.agw_key_vault_cert_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                            | data source |
| [azurerm_key_vault_secret.agw_key_vault_cert_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                             | data source |
| [azurerm_resource_group.key_vault_cert_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                         | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                                        | data source |
| [azurerm_subnet.agw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                                                                                | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network)                                                                    | data source |

## Inputs

| Name                                                                                                                           | Description                                                                                                                                                | Type           | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_agw_aks_ip"></a> [agw_aks_ip](#input_agw_aks_ip)                                                                | The private IP address of the Azure Kubernetes Service (AKS) internal <br/>load balancer backend.                                                          | `string`       | n/a     |   yes    |
| <a name="input_agw_backend_host"></a> [agw_backend_host](#input_agw_backend_host)                                              | The target host header or FQDN expected by the Traefik ingress <br/>controller for routing.                                                                | `string`       | n/a     |   yes    |
| <a name="input_agw_key_vault_cert_name_private"></a> [agw_key_vault_cert_name_private](#input_agw_key_vault_cert_name_private) | Name of the Key Vault secret that stores the private certificate                                                                                           | `string`       | `null`  |    no    |
| <a name="input_agw_key_vault_cert_name_public"></a> [agw_key_vault_cert_name_public](#input_agw_key_vault_cert_name_public)    | Name of the Key Vault secret that stores the public certificate                                                                                            | `string`       | n/a     |   yes    |
| <a name="input_agw_key_vault_cert_rg"></a> [agw_key_vault_cert_rg](#input_agw_key_vault_cert_rg)                               | Key Vault Certificate Resource Group                                                                                                                       | `string`       | n/a     |   yes    |
| <a name="input_agw_key_vault_name"></a> [agw_key_vault_name](#input_agw_key_vault_name)                                        | Name of Existing Key Vault containing public/private <br/> certificates stored as secrets                                                                  | `string`       | n/a     |   yes    |
| <a name="input_agw_nbs_ip_private"></a> [agw_nbs_ip_private](#input_agw_nbs_ip_private)                                        | Private IP address for the internal NBS 6 backend service target<br/>pool.                                                                                 | `string`       | `null`  |    no    |
| <a name="input_agw_private_backend_host"></a> [agw_private_backend_host](#input_agw_private_backend_host)                      | The target backend host header/FQDN used for internal routing by<br/> the Application Gateway.                                                             | `string`       | `null`  |    no    |
| <a name="input_agw_private_hostname"></a> [agw_private_hostname](#input_agw_private_hostname)                                  | The private FQDN mapped to the Application Gateway private listener                                                                                        | `string`       | `null`  |    no    |
| <a name="input_agw_private_ip"></a> [agw_private_ip](#input_agw_private_ip)                                                    | The static private IP address assigned to the Application Gateway<br/> frontend configuration.                                                             | `string`       | `null`  |    no    |
| <a name="input_agw_public_hostname"></a> [agw_public_hostname](#input_agw_public_hostname)                                     | The public FQDN mapped to the Application Gateway public listener.                                                                                         | `string`       | n/a     |   yes    |
| <a name="input_agw_resource_group_name"></a> [agw_resource_group_name](#input_agw_resource_group_name)                         | The name of the Application Gateway resource group                                                                                                         | `string`       | n/a     |   yes    |
| <a name="input_agw_role_definition_name"></a> [agw_role_definition_name](#input_agw_role_definition_name)                      | The Azure RBAC role definition name (e.g., 'Key Vault Secrets User') <br/> assigned to the Application Gateway identity for secret access.                 | `string`       | `""`    |    no    |
| <a name="input_agw_subnet_name"></a> [agw_subnet_name](#input_agw_subnet_name)                                                 | Subnet for Application Gateway deployment                                                                                                                  | `string`       | n/a     |   yes    |
| <a name="input_agw_vnet_name"></a> [agw_vnet_name](#input_agw_vnet_name)                                                       | The name of the Azure Virtual Network (VNet) containing the <br/> Application Gateway subnet.                                                              | `string`       | n/a     |   yes    |
| <a name="input_enable_dual_gateway"></a> [enable_dual_gateway](#input_enable_dual_gateway)                                     | Controls whether to share a single Application Gateway for NBS 7 <br/> and NBS 6 traffic. When set to false, a separate gateway is required for<br/> NBS 6 | `bool`         | `true`  |    no    |
| <a name="input_enabled"></a> [enabled](#input_enabled)                                                                         | Whether to have Terraform provision the resources from this module <br/> in your Azure subscription                                                        | `bool`         | `true`  |    no    |
| <a name="input_nsg_akamai_ips"></a> [nsg_akamai_ips](#input_nsg_akamai_ips)                                                    | List of Akamai IPs to allow inbound traffic on port 443. Supports<br/> IPv4 addresses and CIDR blocks.                                                     | `list(string)` | `[]`    |    no    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                 | Prefix used for naming module resources                                                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_role_based_kv"></a> [role_based_kv](#input_role_based_kv)                                                       | Specifies whether the Key Vault uses Azure Role-Based Access Control <br/>(RBAC) instead of access policies.                                               | `bool`         | `false` |    no    |

## Outputs

| Name                                                                       | Description |
| -------------------------------------------------------------------------- | ----------- |
| <a name="output_agw_public_ip"></a> [agw_public_ip](#output_agw_public_ip) | n/a         |
| <a name="output_public_agw_id"></a> [public_agw_id](#output_public_agw_id) | n/a         |

<!-- END_TF_DOCS -->
