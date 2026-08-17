# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/k8s-namespace

## Description

This module is used to deploy and configure the Prometheus/Grafana Kubernetes namespace for NBS7.

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                         | Type     |
| ---------------------------------------------------------------------------------------------------------------------------- | -------- |
| [kubernetes_namespace.example](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name                                                                              | Description                          | Type     | Default | Required |
| --------------------------------------------------------------------------------- | ------------------------------------ | -------- | ------- | :------: |
| <a name="input_create_namespace"></a> [create_namespace](#input_create_namespace) | Set to true to create the namespace  | `bool`   | n/a     |   yes    |
| <a name="input_namespace_name"></a> [namespace_name](#input_namespace_name)       | The name of the Kubernetes namespace | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
