# 1-nbs6 parameter inputs
#
# Search and replace EXAMPLE_ with relevant value

# Common variables
resource_prefix   = "EXAMPLE_RESOURCE_PREFIX" # highly recommend using snake case for naming (e.g. this-is-snake-case)

# rds module
db_instance_type = "db.m6i.xlarge"
db_snapshot_identifier = "EXAMPLE_SNAPSHOT_ID"
ingress_security_group_id = null
additional_ingress_cidr = ""
vpc_id = "EXAMPLE_VPC_ID"
database_subnets  = ["EXAMPLE_SUBNET_ID"] # subnet_ids must be a part of the provided VPC id
