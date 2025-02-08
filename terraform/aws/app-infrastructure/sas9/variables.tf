variable "vpn_cidr_block" {
    description = "vpn vpc cidr block from which to ssh into ec2"
    default = "10.3.0.0/16"
}

variable "vpc_cidr_block" {
    description = "vpc cidr allowing traffic to rds and wildfly"
}

variable "sas9_ami" {
    description = "sas9 ami from shared services account"
}