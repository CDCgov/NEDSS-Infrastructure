# 0-landing-zone parameter inputs
#
# Search and replace EXAMPLE and OCTET

# Please refer to the commentary in ./variables.tf for more info about the variables below.

resource_prefix = "EXAMPLE_RESOURCE_PREFIX" # Highly recommend using snake case for naming (e.g. this-is-snake-case)

# Modernization Infrastructure
# VPC Variables
cidr            = "10.OCTET2a.0.0/16"
azs             = ["us-east-1a", "us-east-1b"] # Fill in your region(s)
private_subnets = ["10.OCTET2a.1.0/24", "10.OCTET2a.3.0/24"]
public_subnets  = ["10.OCTET2a.2.0/24", "10.OCTET2a.4.0/24"]
