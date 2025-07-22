# Serial: 2025071001

module "ebs" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/ebs?ref=release-7.11.0-rc1"
  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/development-infrastructure/ebs"

}
