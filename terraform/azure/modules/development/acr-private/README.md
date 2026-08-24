# Terraform Azure Module: development/acr-private

## Description

This module deploys and configures NBS 7 development resources for Azure Container Registry (ACR).

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |

### Providers

| Name                                                         | Version      |
| ------------------------------------------------------------ | ------------ |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >=4.68, <5.0 |

### Resources

| Name                                                                                                                                              | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)              | resource    |
| [azurerm_private_endpoint.acr_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                 | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                    | data source |
| [azurerm_subnet.acr_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                            | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network)                | data source |

### Inputs

| Name                                                                                                   | Description                                                                     | Type     | Default | Required |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_acr_resource_group_name"></a> [acr_resource_group_name](#input_acr_resource_group_name) | The name of the resource group                                                  | `string` | n/a     |   yes    |
| <a name="input_acr_subnet_name"></a> [acr_subnet_name](#input_acr_subnet_name)                         | ACR Registry Subnet                                                             | `string` | n/a     |   yes    |
| <a name="input_acr_vnet_name"></a> [acr_vnet_name](#input_acr_vnet_name)                               | Name of vNet                                                                    | `string` | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                         | Prefix used for naming all resources. Only alpha numeric characters are allowed | `string` | n/a     |   yes    |

### Outputs

| Name                                                                                | Description |
| ----------------------------------------------------------------------------------- | ----------- |
| <a name="output_acr_login_server"></a> [acr_login_server](#output_acr_login_server) | n/a         |

<!-- END_TF_DOCS -->
