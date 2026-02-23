# SAMPLES

This directory contains a sample for deploying NBS 7 install using a layered
Terraform approach. Each layer deploys infrastructure or application components 
referenced in subsequent layers. If you select not to deploy a specific layer, you 
must ensure resoure that layer would have provisioned exist and are accessible
within your environment. These resources are ingested via Terraform `data` calls
which query your environemnt. Each layer will by default deploy all modules contained within.

## Assumptions
The current deployment of NBS7 assumes there is a functional NBS6 installation. If NBS6 does exist
you may skip the `1-nbs6` layer.

## Directories
- 0-landing-zone: Provisions network components. For full list of modules please reference the [README](./0-landing-zone/README.md) 
  for this layer.
- 1-nbs6: Provisions NBS6 components (currently just Relation Database Service (RDS)). For full list of modules please reference the [README](./1-nbs6/README.md) 
  for this layer.
- 2-nbs7: Provision NBS7 components. For full list of modules please reference the [README](./2-nbs7/README.md) 
  for this layer.
- 3-applications: Provisions applications to a Kubernetes Clusters. For full list of modules please reference the [README](./3-applications/README.md) 
  for this layer.
- archive: Contains previous deployment samples of NBS7 
  <details>
  <summary><strong> directories</strong></summary>

    - NBS7_standard: will create a new VPC and integrate with existing system  
    - NBS7_existing_network: assumes the network is created in advance outside of terraform  
    - NBS7_2_subnet: limited to two pre-existing subnets - not recently tested as of 08/2024  
    - NBS6_7: deploys resources for both NBS 6 (Classic) and NBS 7 (modern) 
      including a sample database seeded with example data, contact CDC for. 
      access to appropriate database backup. 
    - NBS6_standalone: deploys resources for both NBS 6 (Classic) 
      including a sample database seeded with example data, contact CDC for 
      access to appropriate database backup - most likely you will want to use
      NBS6_7 in preference to this sample
  </details>

## General Deployment Strategy
1. Create a copy of the directory layers provided (0-landing-zone, 1-nbs6, 2-nbs7, 3-applications)
   - Ideally this copy will be your reference for future deployment and should be treated as you would any **code**

2. Follow the steps for each directory (skipping undesired layers)

  - Change directories to desired layer
  - Review README for required (and optional) variable inputs
  - Make desired changes in terraform.tfvars (and optionally variables.tf)
  - Run 
  ```
  terraform init
  terraform plan # review resources created
  terraform apply
  ```