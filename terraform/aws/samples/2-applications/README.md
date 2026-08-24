# Terraform Module Layer: 2-applications

## Description

This Terraform module layer provisions applications being deployed to Kubernetes and expects certain upstream infrastructure
to already exist (VPCs, subnets, IAM roles, AWS EKS etc.). This README explains how those dependencies are referenced.

## 🧭 Purpose & Scope

This module:

- Does not create foundational infrastructure
- Consumes upstream resources via data sources or inputs
- Is intended to be used after core NBS 7 layers

Typical usage:

- 0-landing-zone → 1-nbs7 → **2-applications \(this module)**
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites

- Terraform >= 1.15.6
- AWS CLI configured
- Access to required AWS accounts
- Network connection if Kuberentes cluster is has its API endpoint set to private

## 🔗 Upstream Dependencies

<details>
<summary><strong> Kubernetes Dependencies</strong></summary>

A Kubernetes cluster must already exist and is referenced as described below:

| Resource             | Description                                                                                                                                | How It’s Referenced    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------- |
| resource_prefix      | Typical deployment variable for provisioned resources. Automaticaly creates `name` input. Use either this input or `aws_eks_cluster_name`. | `data.aws_eks_cluster` |
| aws_eks_cluster_name | Second option to use custom AWS EKS name. Use either this input or `resource_prefix`.                                                      | `aws_eks_cluster`      |

</details>

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                | >= 3.1.1, < 4.0.0  |

### Providers

| Name                                             | Version            |
| ------------------------------------------------ | ------------------ |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 6.21.0, < 7.0.0 |

### Modules

| Name                                                     | Source                               | Version |
| -------------------------------------------------------- | ------------------------------------ | ------- |
| <a name="module_linkerd"></a> [linkerd](#module_linkerd) | ../../modules/2-applications/linkerd | n/a     |

### Resources

| Name                                                                                                                   | Type        |
| ---------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_eks_cluster.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |

### Inputs

| Name                                                                                          | Description                                                                                                                                 | Type     | Default | Required |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                | Prefix for resource names                                                                                                                   | `string` | n/a     |   yes    |
| <a name="input_aws_eks_cluster_name"></a> [aws_eks_cluster_name](#input_aws_eks_cluster_name) | Name of EKS cluster. Usually naming follows convention 'var.resource_prefix-eks'. Leave as null to interpret from resource_prefix variables | `string` | `null`  |    no    |

<!-- END_TF_DOCS -->
