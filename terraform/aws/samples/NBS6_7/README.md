# Serial: 2025015501
# SAMPLES

# Last updated/tested 20250115
This directory contains sample terraform deployment files for a combined NBS6 and NBS 7 install
You will need to contact CDC to get access to the latest database snapshot

## Assumptions
This samples subdirectory assumes you have full administrative access to an AWS account 
It will deploy separate VPCs for NBS6 (Classic) and NBS7 and integrate them
together.

## Preparation
- you will need an example RDS snapshot with sample data from of the NBS Classic system, this may be
  shared one of two ways from CDC

- an RDS snapshot will be shared with the target AWS account 
- Log into the Target Account

- View Shared Snapshots: In the RDS Console, you should be able to see the
shared snapshot under Snapshots by choosing Shared With Me from the filter
options.

- Copy Snapshot : the target account must copy the shared
snapshot into their own account. This allows youo to create DB
instances from the snapshot independently.

- another option is a database backup stored in S3 - this will require
  creating a new database (MS SQL), restoring the DB data into this
instance (using ms sql tools or aws DMS) THEN taking a snapshot of the data

- create an ec2 key pair for use, reference it in inputs.tfvars
ec2_key_name           = "cdc-nbs-ec2-EXAMPLE_SITE_NAME"

- copy wildfly zip file to <artifacts_bucket_name>/nbs/<filename.zip>


## After or during the terraform install - if hosting top level domain
elsewhere add the delegation from the public
  route53 address to the authoritative servers for the subdomain created
with terraform, you MAY get an error if it is hosted in an account you
don't have permissions from the user running terraform

## Install steps

- reference the install guide for the specific commands for each stage of
  install with the exception of WHICH samples directory to copy


## File Descriptions
Used in both NBS Classic(6) and NBS 7:
--------------
- dns.tf - deploys required records in a locally hosted route53 subdomain and can delegate parent domain hosting if hosted in the same account or an account with a cross account role defined 
- variables-common.tf - variable definition and defaults shared between NBS6 and 7
- terraform.tf.tpl - template to configure terraform backend where state
  file is stored, example uses s3

NBS6/Classic
------------
- ebs.tf - AWS EC2 volume if NBS6 is hosted on an AWS virtual machine
- nbs-legacy.tf - EC2, container and other resources used for NBS6
- nbs-legacy-vpc.tf - VPC used for NBS 6 only
- variables-6.tf - variable definition and defaults for NBS6
- rds.tf - deploys NBS6 database on an AWS RDS instance

NBS7
----------------------------
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
