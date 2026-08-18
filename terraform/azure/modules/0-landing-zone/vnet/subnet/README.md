# Terraform Azure Module: vnet/subnet

## Description

This module is used to deploy and configure subnets in Azure Virtual Networks (VNets) for NBS7.

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

| Name                                                                                                          | Type     |
| ------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |

## Inputs

| Name                                                                                          | Description                 | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | Default | Required |
| --------------------------------------------------------------------------------------------- | --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)    | Name of the resource group  | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | n/a     |   yes    |
| <a name="input_subnet"></a> [subnet](#input_subnet)                                           | Subnet configuration        | <pre>object({<br/> name = string<br/> address_prefixes = list(string)<br/><br/> private_endpoint_network_policies = optional(string, "Enabled")<br/> private_link_service_network_policies_enabled = optional(bool, true)<br/><br/> service_endpoints_with_location = optional(list(object({<br/> service = string<br/> locations = list(string)<br/> })), [])<br/><br/> service_endpoint_policy_ids = optional(list(string), [])<br/><br/> delegations = optional(list(object({<br/> name = string<br/> service_delegation = object({<br/> name = string<br/> actions = optional(list(string), [])<br/> })<br/> })), [])<br/> })</pre> | n/a     |   yes    |
| <a name="input_virtual_network_name"></a> [virtual_network_name](#input_virtual_network_name) | Name of the virtual network | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | n/a     |   yes    |

## Outputs

| Name                                                                 | Description          |
| -------------------------------------------------------------------- | -------------------- |
| <a name="output_subnet"></a> [subnet](#output_subnet)                | Full subnet resource |
| <a name="output_subnet_id"></a> [subnet_id](#output_subnet_id)       | ID of the subnet     |
| <a name="output_subnet_name"></a> [subnet_name](#output_subnet_name) | Name of the subnet   |

<!-- END_TF_DOCS -->
