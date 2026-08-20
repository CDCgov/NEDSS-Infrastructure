# Terraform Module Layer: 0-landing-zone

## Description

This Terraform module layer provisions infrastructure required to run nbs6 and nbs7. This README details what is providing within the
0-landing-zone module.

## 🧭 Purpose & Scope

This module:

- **Creates foundational infrastructure**

Typical usage:

- **0-landing-zone \(this module)** → 1-nbs7 → 2-applications
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites

- Terraform >= 1.15.6
- AWS CLI configured
- Access to required AWS accounts

## Quick Steps

```bash
# Download appropriate GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
unzip <nbs-infrastructure-v<VERSION>.zip # replace version with your downloaded version
cd terraform/aws/samples/0-landing-zone
terraform init
terraform plan
terraform apply
```

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                | >= 3.1.1, < 4.0.0  |

### Modules

| Name                                                                                   | Source                           | Version |
| -------------------------------------------------------------------------------------- | -------------------------------- | ------- |
| <a name="module_modernization-vpc"></a> [modernization-vpc](#module_modernization-vpc) | ../../modules/0-landing-zone/vpc | n/a     |

### Inputs

| Name                                                                                                | Description                                                          | Type        | Default | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | ----------- | ------- | :------: |
| <a name="input_azs"></a> [azs](#input_azs)                                                          | List of AWS availability zones in current region                     | `list(any)` | n/a     |   yes    |
| <a name="input_cidr"></a> [cidr](#input_cidr)                                                       | CIDR block of your VPC                                               | `any`       | n/a     |   yes    |
| <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)                      | List of CIDR blocks for each private subnets to be created           | `list(any)` | n/a     |   yes    |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)                         | List of CIDR blocks for each public subnets to be created            | `list(any)` | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                      | Prefix to be used on the names of all the resources as an identifier | `string`    | n/a     |   yes    |
| <a name="input_create_igw"></a> [create_igw](#input_create_igw)                                     | Create an internet gateway(requires public subnet)?                  | `bool`      | `true`  |    no    |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames)       | Enable DNS hostnames in the VPC?                                     | `bool`      | `true`  |    no    |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support)             | Enable DNS support in the VPC?                                       | `bool`      | `true`  |    no    |
| <a name="input_enable_nat_gateway"></a> [enable_nat_gateway](#input_enable_nat_gateway)             | Create NAT Gateway?                                                  | `bool`      | `true`  |    no    |
| <a name="input_one_nat_gateway_per_az"></a> [one_nat_gateway_per_az](#input_one_nat_gateway_per_az) | Use a single NAT Gateway for each availability zone?                 | `bool`      | `false` |    no    |
| <a name="input_single_nat_gateway"></a> [single_nat_gateway](#input_single_nat_gateway)             | Use a single NAT Gateway (low availability)?                         | `bool`      | `true`  |    no    |

<!-- END_TF_DOCS -->
