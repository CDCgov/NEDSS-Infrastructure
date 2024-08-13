# SAMPLES

This directory contains samples for typical scenarios of NBS 7 install

## Assumptions
All current samples subdirectories assume there is a functional NBS6
installation in an existing AWS account and VPC

## Directories
- NBS7_standard: will create a new VPC and integrate with existing system
- NBS7_existing_network: assumes the network is created in advance outside of terraform
- NBS7_2_subnet: limited to two pre-existing subnets - not recently tested
  as of 08/2024
