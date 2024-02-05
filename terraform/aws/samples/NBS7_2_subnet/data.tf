data "aws_vpc" "vpc_1" {
  id = ""
}

data "aws_subnet" "subnet_c" {
  id = ""
}

data "aws_subnet" "subnet_d" {
  id = ""
}

data "aws_subnet" "db_subnet_c" {
  id = ""
}

data "aws_subnet" "db_subnet_b" {
  id = ""
}

locals {
  list_azs = [data.aws_subnet.subnet_c.availability_zone,data.aws_subnet.subnet_d.availability_zone]
  list_subnet_cidr = [data.aws_subnet.subnet_c.cidr_block,data.aws_subnet.subnet_d.cidr_block]
  list_subnet_ids = [data.aws_subnet.subnet_c.id,data.aws_subnet.subnet_d.id]
  csv_list_db_subnet_ids = [data.aws_subnet.db_subnet_b.id,data.aws_subnet.db_subnet_c.id]
}