# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

# Variables expressed in CIDR notation are of the format "d.d.d.d/c" (where each "d" is 1-3 digits, and "c" represents the CIDR which is 1-2 digits).

################################################################################

# These vars are used at least by the vnet module:

# The name that will be given to your VNet
vnet_name = "<your_environment_name>-nbs7"

# Specify the address space you want for your VNet
vnet_address_space = ["<your_CIDR_notation_value>"]

# Uncomment this line and specify a value if you want a different region than the one specified by the default value in ./variables.tf
# vnet_location            = "<your_region>"

# As noted in ./variables.tf, this Resource group must already exist
vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"

# Retrieve this via running the following command: az account show --query id
subscription_id = "<your_Azure_subscription_id>"

################################################################################

# If you change a *_dns_zone_enabled variable below to false, then the corresponding *_domain_name variable below is unused (in which case you do not need to specify a value for it).

# Used by the public-dns-zone module:
public_dns_zone_enabled = true
public_domain_name      = "az.<your_STLT_name>nbs.com"

# Used by the private-dns-zone module:
private_dns_zone_enabled = true
private_domain_name      = "az.<your_STLT_name>nbs.com"

################################################################################

# Used by the keyvault module (uncomment any of these optional variables that you have a use case for):

# keyvault_firewall_ip_rules = [
#   "<your_CIDR_notation_value>",
#   "<your_CIDR_notation_value>"
# ]

# e.g. in Azure portal go to Groups, All groups, click on the given group and use its Object ID for 'principal_id' (and set 'principal_type' to "Group").
# Info about each attribute in the object:
#  * principal_id: The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to.
#  * role: Either The name of a built-in Role (e.g. Key Vault Administrator), or a full role definition resource ID for custom roles.
#    ** To see the built-in Roles: in Azure Portal go to Resource groups, click on any existing Resource group, Access control (IAM), Roles.
#  * principal_type: The type of the principal_id. Possible values are User, Group and ServicePrincipal.
# keyvault_role_assignments = {
#   "<name of Principal>" = {
#     principal_id   = "<principal_id>"
#     role           = "<role>"
#     principal_type = "<principal_type>"
#   }
# }

################################################################################

# Set each of these variables to the address_prefixes to be used for the given subnet that will be provisioned:
subnet__public_gateways__address_prefixes = ["<your_CIDR_notation_value>"]
subnet__aks__address_prefixes             = ["<your_CIDR_notation_value>"]
subnet__hdikafka__address_prefixes        = ["<your_CIDR_notation_value>"]
subnet__endpoint__address_prefixes        = ["<your_CIDR_notation_value>"]
