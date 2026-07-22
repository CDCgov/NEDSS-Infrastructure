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
| [azurerm_application_gateway.agw_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway)                                                        | resource    |
| [azurerm_key_vault_access_policy.agw_mi_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)                                              | resource    |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                                          | resource    |
| [azurerm_public_ip.agw_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)                                                                          | resource    |
| [azurerm_role_assignment.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                        | resource    |
| [azurerm_subnet_network_security_group_association.nsg_subnet_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource    |
| [azurerm_user_assigned_identity.agw_mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)                                                       | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                                                     | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)                                                                           | data source |
| [azurerm_key_vault_secret.agw_key_vault_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                                    | data source |
| [azurerm_resource_group.key_vault_cert_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                         | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                                        | data source |
| [azurerm_subnet.agw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                                                                                | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network)                                                                    | data source |

## Inputs

| Name                                                                                                      | Description                          | Type        | Default | Required |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------ | ----------- | ------- | :------: |
| <a name="input_agw_aci_ip"></a> [agw_aci_ip](#input_agw_aci_ip)                                           | ACI IP(s) List                       | `list(any)` | n/a     |   yes    |
| <a name="input_agw_backend_host"></a> [agw_backend_host](#input_agw_backend_host)                         | URL Expected by Traefik Ingress      | `string`    | n/a     |   yes    |
| <a name="input_agw_key_vault_cert_name"></a> [agw_key_vault_cert_name](#input_agw_key_vault_cert_name)    | Key Vault Certificate Name           | `string`    | n/a     |   yes    |
| <a name="input_agw_key_vault_cert_rg"></a> [agw_key_vault_cert_rg](#input_agw_key_vault_cert_rg)          | Key Vault Certificate Resource Group | `string`    | n/a     |   yes    |
| <a name="input_agw_key_vault_name"></a> [agw_key_vault_name](#input_agw_key_vault_name)                   | Key Vault Name                       | `string`    | n/a     |   yes    |
| <a name="input_agw_private_ip"></a> [agw_private_ip](#input_agw_private_ip)                               | AGW Private IP Address               | `string`    | n/a     |   yes    |
| <a name="input_agw_resource_group_name"></a> [agw_resource_group_name](#input_agw_resource_group_name)    | The name of the resource group       | `string`    | n/a     |   yes    |
| <a name="input_agw_role_definition_name"></a> [agw_role_definition_name](#input_agw_role_definition_name) | Name of the role to use with agw     | `string`    | `""`    |    no    |
| <a name="input_agw_subnet_name"></a> [agw_subnet_name](#input_agw_subnet_name)                            | Subnet to deploy App Gateway in      | `string`    | n/a     |   yes    |
| <a name="input_agw_vnet_name"></a> [agw_vnet_name](#input_agw_vnet_name)                                  | Name of vNet                         | `string`    | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                            | Prefix used for naming all resources | `string`    | n/a     |   yes    |
| <a name="input_role_based_kv"></a> [role_based_kv](#input_role_based_kv)                                  | Keyvault uses roles                  | `bool`      | `false` |    no    |

## Outputs

| Name                                                                          | Description |
| ----------------------------------------------------------------------------- | ----------- |
| <a name="output_private_agw_id"></a> [private_agw_id](#output_private_agw_id) | n/a         |

<!-- END_TF_DOCS -->
