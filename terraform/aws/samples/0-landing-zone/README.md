# Terraform Module: 0-landing-zone

This Terraform module layer provisions infrastructure required to run nbs6 and nbs7. This README details what is providing within the
0-landing-zone module.

## 🧭 Purpose & Scope

This module:
- **Creates foundational infrastructure**

Typical usage:
- **0-landing-zone \(this module)** → 1-nbs6 → 2-nbs7 → 3-applications 
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites
- Terraform >= 1.11.0 # if using state locking (>=1.5.7 otherwise)
- AWS CLI configured
- Access to required AWS accounts

## 🔗 Upstream Dependencies 

N/A

##  🚀 Installation

<details>
<summary><strong>Modules </strong></summary>

- Virtual Private Network (VPC)

</details>

<details>
<summary><strong>Required input varaibles (terraform.tfvars) </strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| cidr | CIDR block of your VPC |  |
| azs | List of AWS availability zones in current region |  |
| private_subnets | List of CIDR blocks for each private subnets to be created |  |
| public_subnets | List of CIDR blocks for each private subnets to be created |  |

</details>

<details>
<summary><strong> All input variables (variables.tf)</strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| cidr | CIDR block of your VPC |  |
| azs | List of AWS availability zones in current region |  |
| private_subnets | List of CIDR blocks for each private subnets to be created |  |
| public_subnets | List of CIDR blocks for each private subnets to be created |  |
| create_igw | Create an internet gateway(requires public subnet)? | `true` |
| enable_nat_gateway | Create NAT Gateway? | `true` |
| single_nat_gateway | Use a single NAT Gateway (low availability)? | `true` |
| one_nat_gateway_per_az | Use a single NAT Gateway for each availability zone? | `false` |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `true` |
| enable_dns_support | Should be true to enable DNS support in the VPC | `true` |



</details>

<details>
<summary><strong>Installation</strong></summary>

## Quick Steps
```bash
# Download appropriate GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
unzip <nbs-infrastructure-v<VERSION>.zip # replace version with your downloaded version
cd terraform/aws/samples/0-landing-zone
terraform init
terraform plan
terraform apply