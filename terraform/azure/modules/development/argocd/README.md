# Terraform Azure Module: development/argocd

## Description

This module is used to deploy and configure NBS7 development resources for ArgoCD.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.68, <5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=3.1.1 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=3.1.1 |

### Resources

| Name | Type |
| ---- | ---- |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD with which to bootstrap EKS cluster | `string` | `"5.27.1"` | no |
| <a name="input_deploy_argocd_helm"></a> [deploy\_argocd\_helm](#input\_deploy\_argocd\_helm) | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? | `string` | `"false"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |
<!-- END_TF_DOCS -->
