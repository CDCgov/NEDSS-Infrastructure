module "efs" {
  source          = "../../app-infrastructure/efs"
  resource_prefix = var.resource_prefix
  vpc_id          = data.aws_vpc.nbs7.id
  vpc_cidrs = [
    for subnet in data.aws_subnet.nbs7 :
    subnet.cidr_block
  ]
  kms_key_arn = module.kms.kms_key_arn

  mount_targets = {
    for _, subnet in data.aws_subnet.nbs7 :
    subnet.availability_zone => {
      subnet_id = subnet.id
    }
  }
}
