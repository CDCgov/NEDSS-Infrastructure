# Deploying AWS Resource with Terraform

## Description

This directory is a template to create a new a account to run a copy of CDC
NBS.  Hopefully the environments will converge and all accounts will have
the very similar *.tf files (main.tf is the core) with some of the modules
not needed for every environment.  e.g. if Kafka/MSK is not needed for database
analysis leave msk.tf out of the account/environment directory.

inputs.tfvars will contain all the NON secret environment specific data.

## Values

Below are the available Variables contained within this template

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
example list |  list(string) | | list of emails to send alerts
example | string | | example description one
example | string | | example description


## TODO
Scripts to prompt to fill unknown variables, check aws dependencies,
compare files

