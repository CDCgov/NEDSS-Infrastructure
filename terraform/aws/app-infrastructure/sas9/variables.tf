variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "vpn_cidr_block" {
  description = "vpn vpc cidr block from which to ssh into ec2"
  default     = "10.3.0.0/16"
}

variable "vpc_cidr_block" {
  description = "vpc cidr allowing traffic to rds and wildfly"
}

variable "sas_ami" {
  description = "sas9 ami from shared services account"
}

variable "sas_keypair_name" {
  description = "sas9 ami from shared services account"
}

variable "sas_instance_type" {
  description = "sas9 ami from shared services account"
}

variable "sas_kms_key_id" {
  description = "kms key arn to be used to encrypt root volume"
}

variable "sas_root_volume_size" {
  description = "root volume size for sas server"
  default     = "200"
}

variable "sas_subnet_id" {
  description = "private subnet for sas server"
}

variable "sas_vpc_id" {
  description = "vpc id for the sas security group"
}
