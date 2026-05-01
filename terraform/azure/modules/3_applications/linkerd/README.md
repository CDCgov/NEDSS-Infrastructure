<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=3.1.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.linkerd_control_plane](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.linkerd_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.linkerd_viz](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [tls_cert_request.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | n/a | `string` | `"dev-aks"` | no |
| <a name="input_create_linkerd_viz"></a> [create\_linkerd\_viz](#input\_create\_linkerd\_viz) | n/a | `bool` | `true` | no |
| <a name="input_linkerd_chart"></a> [linkerd\_chart](#input\_linkerd\_chart) | n/a | `string` | `"linkerd-crds"` | no |
| <a name="input_linkerd_controlplane_chart"></a> [linkerd\_controlplane\_chart](#input\_linkerd\_controlplane\_chart) | n/a | `string` | `"linkerd-control-plane"` | no |
| <a name="input_linkerd_namespace_name"></a> [linkerd\_namespace\_name](#input\_linkerd\_namespace\_name) | n/a | `string` | `"linkerd"` | no |
| <a name="input_linkerd_repository"></a> [linkerd\_repository](#input\_linkerd\_repository) | n/a | `string` | `"https://helm.linkerd.io/stable"` | no |
| <a name="input_linkerd_viz_chart"></a> [linkerd\_viz\_chart](#input\_linkerd\_viz\_chart) | n/a | `string` | `"linkerd-viz"` | no |
| <a name="input_linkerd_viz_namespace_name"></a> [linkerd\_viz\_namespace\_name](#input\_linkerd\_viz\_namespace\_name) | n/a | `string` | `"linkerd-viz"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->