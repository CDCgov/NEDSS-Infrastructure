# Terraform Azure Module: development/argocd

## Description

This module deploys and configures NBS7 development resources for ArgoCD.

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

### Resources

| Name                                                                                                        | Type     |
| ----------------------------------------------------------------------------------------------------------- | -------- |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name                                                                                    | Description                                                      | Type     | Default     | Required |
| --------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------- | ----------- | :------: |
| <a name="input_argocd_version"></a> [argocd_version](#input_argocd_version)             | Version of ArgoCD with which to bootstrap EKS cluster            | `string` | `"5.27.1"`  |    no    |
| <a name="input_deploy_argocd_helm"></a> [deploy_argocd_helm](#input_deploy_argocd_helm) | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? | `string` | `"false"`   |    no    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)          | Prefix for resource names                                        | `string` | `"cdc-nbs"` |    no    |

<!-- END_TF_DOCS -->
