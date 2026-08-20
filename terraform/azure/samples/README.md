# SAMPLES

This directory contains a sample for deploying NBS 7, using a layered
Terraform approach. Each layer deploys infrastructure or application components
referenced in subsequent layers. If you select not to deploy a specific layer, you
must ensure the resources that layer would have provisioned exist and are accessible
within your environment. These resources are ingested via Terraform `data` calls
which query your environment. Each layer will by default deploy all modules contained within.

## Assumptions

The current deployment of NBS7 assumes there is a functional NBS6 installation.

## Directories

For more details see the `README.md` files within these directories.

- [0-landing-zone](./0-landing-zone): Provisions network components.
- [1-nbs7](./1-nbs7): Provision NBS7 components.
- [2-applications](./2-applications): Deploys applications to a Kubernetes cluster.

## General Deployment Strategy

1. Create a copy of the directory layers provided (i.e. `0-landing-zone`, `1-nbs7`, `2-applications`)
   - Ideally this copy will be your reference for future deployment and should be treated as you would any **code**

2. Follow the steps for each directory (skipping any undesired layers)

- Download desired GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
- `unzip <nbs-infrastructure-v<VERSION>.zip` # replace version with your downloaded version
- Change directories to desired layer, doing each layer in order per the number that each layer's folder name begins with.
- Review the given layer's `README.md` for required (and optional) variable inputs
- Make desired changes in `terraform.tfvars` and `terraform.tf` (and optionally `variables.tf`)
- Run these commands:

```
terraform init
terraform plan -out=tfplan # review the resources that will be provisioned
terraform apply tfplan
```
