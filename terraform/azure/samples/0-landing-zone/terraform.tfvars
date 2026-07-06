# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

# These vars are used at least by the vnet module:
vnet_name          = "<your_environment_name>-nbs7"
vnet_address_space = ["<your_value>"] # Specify the address space you want for your VNet - an example is something of the format (where each "x" is a digit): ["xx.x.x.x/xx"]
# vnet_location            = "<your_region>" # Uncomment this line and specify a value if you want a different region than the one specified by the default value in ./variables.tf
vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"
subscription_id          = "<your_Azure_subscription_id>" # Retrieve this via running the following command: az account show --query id

# If you change a *_dns_zone_enabled variable below to false, then the corresponding *_domain_name variable below is unused (in which case you do not need to specify a value for it).

# Used by the public-dns-zone module:
public_dns_zone_enabled = true
public_domain_name      = "az.<your_STLT_name>nbs.com"

# Used by the private-dns-zone module:
private_dns_zone_enabled = true
private_domain_name      = "az.<your_STLT_name>nbs.com"
