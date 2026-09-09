# Terraform AWS Module: 2-applications/linkerd

## Description

This module deploys and configures linkerd and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                        | Version            |
| --------------------------------------------------------------------------- | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | >= 6.21.0, < 7.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement_grafana)          | >= 4.19.0, < 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | >= 3.1.1, < 4.0.0  |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | >= 2.38.0, < 3.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement_tls)                      | >= 4.1.0, < 5.0.0  |

### Providers

| Name                                                | Version |
| --------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)    | 6.21.0  |
| <a name="provider_helm"></a> [helm](#provider_helm) | 3.1.1   |
| <a name="provider_tls"></a> [tls](#provider_tls)    | 4.1.0   |

### Resources

| Name                                                                                                                              | Type        |
| --------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [helm_release.linkerd_control_plane](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)        | resource    |
| [helm_release.linkerd_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                 | resource    |
| [helm_release.linkerd_viz](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                  | resource    |
| [tls_cert_request.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request)               | resource    |
| [tls_locally_signed_cert.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource    |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                     | resource    |
| [tls_private_key.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)                 | resource    |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert)           | resource    |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth)   | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                       | data source |

### Inputs

| Name                                                                                                                                    | Description                                                              | Type     | Default                            | Required |
| --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | -------- | ---------------------------------- | :------: |
| <a name="input_cluster_certificate_authority_data"></a> [cluster_certificate_authority_data](#input_cluster_certificate_authority_data) | Base64-encoded certificate data required to communicate with the cluster | `string` | n/a                                |   yes    |
| <a name="input_eks_cluster_endpoint"></a> [eks_cluster_endpoint](#input_eks_cluster_endpoint)                                           | The hostname (in form of URI) of the Kubernetes API.                     | `string` | n/a                                |   yes    |
| <a name="input_eks_cluster_name"></a> [eks_cluster_name](#input_eks_cluster_name)                                                       | Name of the EKS cluster                                                  | `string` | n/a                                |   yes    |
| <a name="input_linkerd_crds_chart"></a> [linkerd_crds_chart](#input_linkerd_crds_chart)                                                 | Name of linkerd crds chart                                               | `string` | `"linkerd-crds"`                   |    no    |
| <a name="input_linkerd_crds_chart_version"></a> [linkerd_crds_chart_version](#input_linkerd_crds_chart_version)                         | Version of linkerd crds chart                                            | `string` | `"1.8.0"`                          |    no    |
| <a name="input_linkerd_controlplane_chart"></a> [linkerd_controlplane_chart](#input_linkerd_controlplane_chart)                         | Name of linkerd control plane chart                                      | `string` | `"linkerd-control-plane"`          |    no    |
| <a name="input_linkerd_controlplane_chart_version"></a> [linkerd_controlplane_chart_version](#input_linkerd_controlplane_chart_version) | Version of linkerd control plane chart                                   | `string` | `"1.16.11"`                        |    no    |
| <a name="input_linkerd_namespace_name"></a> [linkerd_namespace_name](#input_linkerd_namespace_name)                                     | Name of linkerd namespace                                                | `string` | `"linkerd"`                        |    no    |
| <a name="input_linkerd_repository"></a> [linkerd_repository](#input_linkerd_repository)                                                 | Repository to use when installing linkerd                                | `string` | `"https://helm.linkerd.io/stable"` |    no    |
| <a name="input_deploy_linkerd_viz"></a> [deploy_linkerd_viz](#input_deploy_linkerd_viz)                                                 | Whether to deploy the linkerd viz chart                                  | `bool`   | `false`                            |    no    |
| <a name="input_linkerd_viz_chart"></a> [linkerd_viz_chart](#input_linkerd_viz_chart)                                                    | Name of linkerd viz chart                                                | `string` | `"linkerd-viz"`                    |    no    |
| <a name="input_linkerd_viz_chart_version"></a> [linkerd_viz_chart_version](#input_linkerd_viz_chart_version)                            | Version of linkerd viz chart                                             | `string` | `"30.12.11"`                       |    no    |
| <a name="input_linkerd_viz_namespace_name"></a> [linkerd_viz_namespace_name](#input_linkerd_viz_namespace_name)                         | Name of linkerd viz namespace                                            | `string` | `"linkerd-viz"`                    |    no    |

<!-- END_TF_DOCS -->
