# SAMPLES

This directory contains samples for typical scenarios of NBS 7 install
In general they are variations on our core terraform deployment files to
address specific scenarios and are not guaranteed tested or updated with each release
The complete files will default to deploying and provisioning ALL resources
from an empty AWS account, the variations usually are using preconfigured resources (DNS, VPCs etc) 
changing the values passed to github hosted modules from something
inherited from another module to a variable defined in inputs.tfvars and
appropriate variables-*.tf file
e.g. 

vpc_id                     = module.modernization-vpc.vpc_id

might be changed to 

vpc_id                     = var.modernization-vpc-id

or

vpc_id                     = data.aws_vpc.vpc_1.id

## Assumptions
Many current samples subdirectories assume there is a functional NBS6
installation in an existing AWS account and VPC

## Directories
- NBS7_standard: will create a new VPC and integrate with existing system
- NBS7_existing_network: assumes the network is created in advance outside of terraform
- NBS7_2_subnet: limited to two pre-existing subnets - not recently tested as of 08/2024
- NBS6_7: deploys resources for both NBS 6 (Classic) and NBS 7 (modern)
  including a sample database seeded with example data, contact CDC for
access to appropriate database backup
- NBS6_standalone: deploys resources for both NBS 6 (Classic) 
  including a sample database seeded with example data, contact CDC for
access to appropriate database backup - most likely you will want to use
NBS6_7 in preference to this sample




## File Descriptions
### Used in both NBS Classic(6) and NBS 7:
---
- dns.tf - deploys required records in a locally hosted route53 subdomain and can delegate parent domain hosting if hosted in the same account or an account with a cross account role defined 
- variables-common.tf - variable definition and defaults shared between NBS6 and 7
- terraform.tf.tpl - template to configure terraform backend where state -
  should be copied and customized
- inputs.tfvars.tpl - template of file defining variables for local setup -
  should be copied and customized 

### NBS6/Classic
---
- ebs.tf - AWS EC2 volume if NBS6 is hosted on an AWS virtual machine
- nbs-legacy.tf - EC2, container and other resources used for NBS6
- nbs-legacy-vpc.tf - VPC used for NBS 6 only
- variables-6.tf - variable definition and defaults for NBS6
- rds.tf - deploys NBS6 database on an AWS RDS instance

### NBS7
---
- efs.tf - persistent file store for containers
- eks.tf - AWS managed kubernetes service
- fluentbit.tf - sets up fluentbit for containers and other resources
- kms.tf - managed KMS key
- linkerd.tf - implements linkerd for MTLS 
- msk.tf - AWS managed kafka service
- nbs-modern-vpc.tf - VPC for NBS7 
- prometheus.tf.disabled - deploys AWS managed prometheus and graphana with a sample dashboard disabled by default with expectation users might have alternative in place
- s3-buckets.tf - fluentbit (and other buckets if needed)
- synthetics-canary.tf.disabled - deploys an AWS cloudwatch synthetics canary to perform basic health checks- disabled  
- variables-7.tf - variable definition and defaults for NBS7
- vpc-endpoints.tf - deploys AWS vpc endpoints when needed
