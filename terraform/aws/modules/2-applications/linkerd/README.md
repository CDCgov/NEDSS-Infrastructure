# Terraform AWS Module: 2-applications/linkerd

## Description

This module is used to deploy and configure linkerd and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 4.19.0, < 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.1.1, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.38.0, < 3.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.1.0, < 5.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [helm_release.linkerd_control_plane](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.linkerd_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.linkerd_viz](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [tls_cert_request.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | Base64-encoded certificate data required to communicate with the cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_linkerd_chart"></a> [linkerd\_chart](#input\_linkerd\_chart) | Name of linkerd chart | `string` | `"linkerd-crds"` | no |
| <a name="input_linkerd_controlplane_chart"></a> [linkerd\_controlplane\_chart](#input\_linkerd\_controlplane\_chart) | Name of linkerd control plane chart | `string` | `"linkerd-control-plane"` | no |
| <a name="input_linkerd_helm_version"></a> [linkerd\_helm\_version](#input\_linkerd\_helm\_version) | linkerd edge helm version | `string` | `"2025.7.3"` | no |
| <a name="input_linkerd_namespace_name"></a> [linkerd\_namespace\_name](#input\_linkerd\_namespace\_name) | Name of linkerd namespace | `string` | `"linkerd"` | no |
| <a name="input_linkerd_repository"></a> [linkerd\_repository](#input\_linkerd\_repository) | Repository to use when installing linkerd | `string` | `"https://helm.linkerd.io/stable"` | no |
| <a name="input_linkerd_viz_chart"></a> [linkerd\_viz\_chart](#input\_linkerd\_viz\_chart) | Name of linkerd viz chart | `string` | `"linkerd-viz"` | no |
| <a name="input_linkerd_viz_namespace_name"></a> [linkerd\_viz\_namespace\_name](#input\_linkerd\_viz\_namespace\_name) | Name of linkerd viz namespace | `string` | `"linkerd-viz"` | no |
<!-- END_TF_DOCS -->
