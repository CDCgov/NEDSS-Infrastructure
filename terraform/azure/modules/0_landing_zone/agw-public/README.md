<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.68, <5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.agw_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_key_vault_access_policy.agw_mi_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.agw_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet_network_security_group_association.nsg_subnet_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.agw_mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.agw_key_vault_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.key_vault_cert_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.agw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agw_aks_ip"></a> [agw\_aks\_ip](#input\_agw\_aks\_ip) | AKS Internal Loadbalancer IP | `string` | n/a | yes |
| <a name="input_agw_backend_host"></a> [agw\_backend\_host](#input\_agw\_backend\_host) | URL Expected by NGINX Ingress | `string` | n/a | yes |
| <a name="input_agw_key_vault_cert_name"></a> [agw\_key\_vault\_cert\_name](#input\_agw\_key\_vault\_cert\_name) | Key Vault Certificate Name | `string` | n/a | yes |
| <a name="input_agw_key_vault_cert_rg"></a> [agw\_key\_vault\_cert\_rg](#input\_agw\_key\_vault\_cert\_rg) | Key Vault Certificate Resource Group | `string` | n/a | yes |
| <a name="input_agw_key_vault_name"></a> [agw\_key\_vault\_name](#input\_agw\_key\_vault\_name) | Existing Key Vault Name. | `string` | n/a | yes |
| <a name="input_agw_resource_group_name"></a> [agw\_resource\_group\_name](#input\_agw\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_agw_role_definition_name"></a> [agw\_role\_definition\_name](#input\_agw\_role\_definition\_name) | Name of the role to use with agw | `string` | `""` | no |
| <a name="input_agw_subnet_name"></a> [agw\_subnet\_name](#input\_agw\_subnet\_name) | Subnet to deploy App Gateway in | `string` | n/a | yes |
| <a name="input_agw_vnet_name"></a> [agw\_vnet\_name](#input\_agw\_vnet\_name) | Name of vNet | `string` | n/a | yes |
| <a name="input_nsg_akamai_ips"></a> [nsg\_akamai\_ips](#input\_nsg\_akamai\_ips) | List of Akamai IPs to allow inbound traffic on port 443 | `list(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix used for naming all resources | `string` | n/a | yes |
| <a name="input_role_based_kv"></a> [role\_based\_kv](#input\_role\_based\_kv) | Keyvault uses roles | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_agw_id"></a> [public\_agw\_id](#output\_public\_agw\_id) | n/a |
<!-- END_TF_DOCS -->