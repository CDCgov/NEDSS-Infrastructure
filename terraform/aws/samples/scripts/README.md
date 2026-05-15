# SCRIPTS

This directory provides scripts and instruction for using each of the scripts contained within. 
Scripts found in this directory are meant to aid with the terraform implementation for AWS resources.

# Contents
- [layered_terraform_migration.py](./scripts/layered_terraform_migration.py): split terraform state from single module into layers. For usage see section [Layered Terraform Migration Script](#layered-terraform-migration-script)

# Layered Terraform Migration Script

## Overview

The purpose of this script is to aid in the transition from using a single directory to deploy your terraform to using the layered terraform approach --  a method which separates terraform resources into logical layers that can be deployed based on preference. The employed method makes use of the `terraform state mv` command which is destructive by nature, but only for your local copy of the state file. State files are typically stored using a remote configuration, best practice, so there usually is no risk when using this script. This script can pull a local copy automatically to be used or one can be manually added.

## Prerequisites
- Python 3.12+
- Additional tooling for deploying terraform to AWS found in the [System Admin Guide](https://cdcgov.github.io/NEDSS-SystemAdminGuide/docs/deploy-nbs7/deploy-on-aws/prerequisites.html#management-machine-setup)

## Quick Reference Table

| Flag | Required | Type | Default | Description |
| :--- | :---: | :---: | :---: | :--- |
| `--source` | **No** | `string` | `./` | Relative or absolute path to directory containing deployed NBS Terraform. Default = this script directory. |
| `--target` | **No** | `string` | `./` | TRelative or absolute path to directory containing target layered NBS Terraform. Default = this script directory. |
| `--pull-fresh` | **No** | `string` | `yes` | Pull a fresh copy of the terraform state (yes/no)? If no, file must be in same directory as this script and be named source.tfstate. |

---

## ⚙️ Detailed Flag Behavior

### 1. `--source` (Directory Context)
The script uses `pathlib` to resolve this input. 
- If a relative path is provided (e.g., `./infra`), it is converted to an **absolute path** internally.
- This ensures that the `cwd` (Current Working Directory) passed to the subprocess is stable, allowing Terraform to correctly resolve relative module paths like `source = "../modules"`.

### 2. `--target` (Directory Context)
The script uses `pathlib` to resolve this input. 
- If a relative path is provided (e.g., `./infra`), it is converted to an **absolute path** internally.
- This ensures that the `cwd` (Current Working Directory) passed to the subprocess is stable, allowing Terraform to correctly resolve relative module paths like `source = "../modules"`.

### 3. `--pull-fresh`
The script uses local cloud credentials to pull a copy of the state file locally.
- Takes values `yes` or `no`. If `no`, requires a preprovided local copy of the state file named `source.tfstate` within the same directory as this script.

---

## 🚀 Usage Example

```bash
# Run a state pull using relative paths for source (all-in-one terraform deployment) using a relative path for the target (layered terraform)
python3 layered_terraform_migration.py --pull-fresh="yes" --source="../archive/NBS7_standalone" --target="../samples"

# Use a local state file and an absolute path for the target (layered terraform)
python3 layered_terraform_migration.py --pull-fresh="no" --target="/Users/sampleUser/Documents/github/NEDSS-Infrastructure/terraform/aws/samples"

