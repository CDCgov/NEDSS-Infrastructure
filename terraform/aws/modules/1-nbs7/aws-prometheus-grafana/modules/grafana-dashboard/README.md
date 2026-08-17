# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/grafana-dashboard

## Description

This submodule is used to deploy and configure the Grafana dashboard and related resources for NBS7.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version           |
| ------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6         |
| <a name="requirement_grafana"></a> [grafana](#requirement_grafana)       | >=4.19.0, < 5.0.0 |

## Providers

| Name                                                         | Version           |
| ------------------------------------------------------------ | ----------------- |
| <a name="provider_grafana"></a> [grafana](#provider_grafana) | >=4.19.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                             | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [grafana_dashboard.prometheus-nginx-ingress-controller](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_data_source.prometheus](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source)                      | resource |
| [grafana_folder.data](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder)                                      | resource |

## Inputs

| Name                                                                                             | Description                                        | Type     | Default         | Required |
| ------------------------------------------------------------------------------------------------ | -------------------------------------------------- | -------- | --------------- | :------: |
| <a name="input_amg_api_token"></a> [amg_api_token](#input_amg_api_token)                         | The API token for Amazon Managed Grafana           | `string` | n/a             |   yes    |
| <a name="input_amp_url"></a> [amp_url](#input_amp_url)                                           | The URL of the Amazon Managed Prometheus workspace | `string` | n/a             |   yes    |
| <a name="input_data_source_uid"></a> [data_source_uid](#input_data_source_uid)                   | The UID to give the Prometheus data source         | `string` | `"prom_ds_uid"` |    no    |
| <a name="input_grafana_workspace_url"></a> [grafana_workspace_url](#input_grafana_workspace_url) | The URL of the Grafana workspace                   | `string` | n/a             |   yes    |
| <a name="input_region"></a> [region](#input_region)                                              | The AWS region to use for the resources            | `string` | n/a             |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
