# Terraform Azure Module: 2-applications/linkerd

## Description

This module deploys and configures linkerd and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6    |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >=4.68, <5.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                | >=3.1.1      |

### Providers

| Name                                                | Version |
| --------------------------------------------------- | ------- |
| <a name="provider_helm"></a> [helm](#provider_helm) | >=3.1.1 |
| <a name="provider_tls"></a> [tls](#provider_tls)    | n/a     |

### Resources

| Name                                                                                                                              | Type     |
| --------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [helm_release.linkerd_control_plane](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)        | resource |
| [helm_release.linkerd_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                 | resource |
| [helm_release.linkerd_viz](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                  | resource |
| [tls_cert_request.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request)               | resource |
| [tls_locally_signed_cert.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                     | resource |
| [tls_private_key.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                 | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert)           | resource |

### Inputs

| Name                                                                                                            | Description                               | Type     | Default                            | Required |
| --------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | -------- | ---------------------------------- | :------: |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                      | Name of the resource group                | `string` | n/a                                |   yes    |
| <a name="input_aks_cluster_name"></a> [aks_cluster_name](#input_aks_cluster_name)                               | Name of the AKS cluster                   | `string` | `"dev-aks"`                        |    no    |
| <a name="input_create_linkerd_viz"></a> [create_linkerd_viz](#input_create_linkerd_viz)                         | Whether to install linkerd viz            | `bool`   | `false`                            |    no    |
| <a name="input_linkerd_chart"></a> [linkerd_chart](#input_linkerd_chart)                                        | Name of linkerd chart                     | `string` | `"linkerd-crds"`                   |    no    |
| <a name="input_linkerd_controlplane_chart"></a> [linkerd_controlplane_chart](#input_linkerd_controlplane_chart) | Name of linkerd control plane chart       | `string` | `"linkerd-control-plane"`          |    no    |
| <a name="input_linkerd_namespace_name"></a> [linkerd_namespace_name](#input_linkerd_namespace_name)             | Name of linkerd namespace                 | `string` | `"linkerd"`                        |    no    |
| <a name="input_linkerd_repository"></a> [linkerd_repository](#input_linkerd_repository)                         | Repository to use when installing linkerd | `string` | `"https://helm.linkerd.io/stable"` |    no    |
| <a name="input_linkerd_viz_chart"></a> [linkerd_viz_chart](#input_linkerd_viz_chart)                            | Name of linkerd viz chart                 | `string` | `"linkerd-viz"`                    |    no    |
| <a name="input_linkerd_viz_namespace_name"></a> [linkerd_viz_namespace_name](#input_linkerd_viz_namespace_name) | Name of linkerd viz namespace             | `string` | `"linkerd-viz"`                    |    no    |

<!-- END_TF_DOCS -->
