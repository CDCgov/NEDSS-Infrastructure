# SAMPLES

This directory contains samples for typical scenarios of NBS 7 install

## Assumptions
All current samples subdirectories assume there is a functional NBS6
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
