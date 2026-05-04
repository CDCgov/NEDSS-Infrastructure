<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~>2.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~>2.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD with which to bootstrap EKS cluster | `string` | `"5.27.1"` | no |
| <a name="input_deploy_argocd_helm"></a> [deploy\_argocd\_helm](#input\_deploy\_argocd\_helm) | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? | `string` | `"false"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->