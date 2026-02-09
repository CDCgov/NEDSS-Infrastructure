# Terraform Module: 3-applications

This Terraform module layer provisions applications being deployed to Kubernetes and **expects certain upstream infrastructure
to already exist** (VPCs, subnets, IAM roles, AWS EKS etc.). This README explains **how those dependencies are referenced**.

## 🧭 Purpose & Scope

This module:
- **Does not create foundational infrastructure**
- **Consumes upstream resources via data sources or inputs**
- Is intended to be used **after** core NBS7 layers

Typical usage:
- 0-landing-zone → 1-nbs6 → 2-nbs7 → **3-applications \(this module)**
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites
- Terraform >= 1.11.0 # if using state locking (>=1.5.7 otherwise)
- AWS CLI configured
- Access to required AWS accounts
- Network connection if Kuberentes cluster is has its API endpoint set to private

## 🔗 Upstream Dependencies 

<details>
<summary><strong> Kubernetes Dependencies</strong></summary>

A Kubernetes cluster **must already exist** and is referenced as described below:

| Resource | Description | How It’s Referenced |
|--------|-------------|---------------------|
| resource_prefix | Typical deployment variable for provisioned resources. Automaticaly creates `name` input. Use either this input or `aws_eks_cluster_name`. | `data.aws_eks_cluster` |
| aws_eks_cluster_name | Second option to use custom AWS EKS name. Use either this input or `resource_prefix`. | `aws_eks_cluster` |


</details>

##  🚀 Installation

<details>
<summary><strong>Modules </strong></summary>

- Linkerd
</details>

<details>
<summary><strong>Required input varaibles (terraform.tfvars) </strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | "Prefix for resource names" | |
</details>

<details>
<summary><strong> All input variables (variables.tf)</strong></summary>

| Parameter | Description | Default |
|--------|-------------| -------------|
| resource_prefix | "Prefix for resource names" | |
| aws_eks_cluster_name | "Name of EKS cluster. Usually naming follows convention 'var.resource_prefix-eks'. Leave as null to interpret from resource_prefix variables" | `null` |
</details>

<details>
<summary><strong>Installation</strong></summary>

## Quick Steps
```bash
# Download appropriate GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
unzip <nbs-infrastructure-v<VERSION>.zip # replace version with your downloaded version
cd terraform/aws/samples/3-applications
terraform init
terraform plan
terraform apply