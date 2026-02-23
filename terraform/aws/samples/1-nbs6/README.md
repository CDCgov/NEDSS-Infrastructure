# Terraform Module: 1-nbs6

This Terraform module layer provisions infrastructure required to run nbs6 and **expects certain upstream infrastructure
to already exist** (VPCs, subnets, IAM roles etc.). This README explains **how those dependencies are referenced**.

## 🧭 Purpose & Scope

This module:
- **Creates foundational NBS6 infrastructure**
- **Consumes upstream resources via data sources or inputs**

Typical usage:
- 0-landing-zone → **1-nbs6 \(this module)** → 2-nbs7 → 3-applications 
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites
- Terraform >= 1.11.0 # if using state locking (>=1.5.7 otherwise)
- AWS CLI configured
- Access to required AWS accounts

## 🔗 Upstream Dependencies 

<details>
<summary><strong> Networking Dependencies</strong></summary>

Networking including VPCs and public hosted zones **must already exist** and are referenced as described below.

| Resource | Description | How It’s Referenced |
|--------|-------------|---------------------|
| vpc_id | VPC ID of virtual private cloud. | `data.aws_vpc` |

</details>

##  🚀 Installation

<details>
<summary><strong>Modules </strong></summary>

- Relational Database Service (RDS)
    - Security Groups
    - Option Group
    - Secrets Manager Secret

</details>

<details>
<summary><strong>Required input varaibles (terraform.tfvars) </strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| db_instance_type | Database instance type | `db.m6i.xlarge` |
| db_snapshot_identifier | Database snapshot to use for RDS isntance |  |
| ingress_security_group_id | Security group id of NBS6 instance to allow traffic into RDS | `null` |
| additional_ingress_cidr | CSV of CIDR blocks which will have access to RDS instance | `""` |
| vpc_id |  |  |
| database_subnets | Subnet Ids to be used when creating RDS |  |


</details>

<details>
<summary><strong> All input variables (variables.tf)</strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| vpc_id | VPC ID of virtual private cloud |  |
| database_subnets | Subnet Ids to be used when creating RDS |  |
| db_instance_type | Database instance type |  |
| db_snapshot_identifier | Database snapshot to use for RDS isntance |  |
| manage_master_user_password | Set to true to allow RDS to manage the master user password in Secrets Manager | `true` |
| ingress_security_group_id | Security group id of NBS6 instance to allow traffic into RDS | `null` |
| additional_ingress_cidr | CSV of CIDR blocks which will have access to RDS instance | `""` |


</details>

<details>
<summary><strong>Installation</strong></summary>

## Quick Steps
```bash
# Download appropriate GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
unzip <nbs-infrastructure-v<VERSION>.zip # replace version with your downloaded version
cd terraform/aws/samples/1-nbs6
terraform init
terraform plan
terraform apply