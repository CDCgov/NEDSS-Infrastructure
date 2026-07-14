# Terraform Layer: 0-landing-zone

## 🧭 Purpose & Scope

This layer:
- **Creates foundational infrastructure**

Typical usage:
- **0-landing-zone \(this layer)** → 1-nbs6 (typically this layer is skipped) → 2-nbs7 → 3-applications 
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites
- Terraform >= 1.11.0 # if using state locking (>=1.5.7 otherwise)
- AWS CLI configured
- Access to required AWS accounts

## 🔗 Upstream Dependencies 

N/A

## Description

Modules
- Virtual Private Network (VPC)

See [terraform.tfvars](./terraform.tfvars) for required input variables, and [variables.tf](./variables.tf) for all input variables.
