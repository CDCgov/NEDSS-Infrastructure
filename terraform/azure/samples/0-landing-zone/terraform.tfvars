# Please refer to the commentary in ./variables.tf for more info about the variables below.

# The README.md at the top level/folder of this repository has info about how you take a copy of this file and revise it. 
# Unless otherwise specified below, replace each of the strings below in angle brackets (i.e. "<some-string>") with info about the NBS 7 environment you are using this Terraform code to provision the infrastructure for.

# Variables expressed in CIDR notation are of the format "d.d.d.d/c" (where each "d" is 1-3 digits, and "c" represents the CIDR which is 1-2 digits).

################################################################################
# Virtual Network
################################################################################

# Retrieve this via running the following command: az account show --query id
subscription_id = "<your_Azure_subscription_id>"

# As noted in ./variables.tf, this Resource group must already exist
vnet_resource_group_name = "nbs7-<your_STLT_name>-<your_environment_name>"

# Uncomment this line and specify a value if you want a different region than the one specified by the default value in ./variables.tf
# vnet_location            = "<your_region>"

# The name that will be given to your VNet
vnet_name = "<your_environment_name>-nbs7"

# Specify the address space you want for your VNet
vnet_address_space = ["<your_CIDR_notation_value>"]

# If you change a *_dns_zone_enabled variable below to false, then the corresponding *_domain_name variable below is unused (in which case you do not need to specify a value for it).


################################################################################
# Subnets
################################################################################

# Set each of these variables to the address_prefixes to be used for the given subnet that will be provisioned:
subnet__public_gateways__address_prefixes = ["<your_CIDR_notation_value>"]
subnet__aks__address_prefixes             = ["<your_CIDR_notation_value>"]
subnet__hdikafka__address_prefixes        = ["<your_CIDR_notation_value>"]
subnet__endpoint__address_prefixes        = ["<your_CIDR_notation_value>"]


################################################################################
# Public DNS Zone
################################################################################

public_dns_zone_enabled = true
public_domain_name      = "az.<your_STLT_name>nbs.com"

# public_dns_zone_dns_records =


################################################################################
# Private DNS Zone
################################################################################

private_dns_zone_enabled = true
private_domain_name      = "az.<your_STLT_name>nbs.com"

# Uncomment to turn off automatic dns registration. (See https://learn.microsoft.com/en-us/azure/dns/private-dns-autoregistration for more information)
# private_dns_zone_registration_enabled = false


################################################################################
# Keyvault
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

# Map of legacy access policies. Applies only when enable_rbac_authorization = false.
# Prefer RBAC for new deployments; use this only to support existing vaults that have not been migrated.
# keyvault_access_policies =

# List of certificate contacts notified on certificate lifecycle events
# (e.g. expiry, auto-renewal failures). At least an email is required;
# name and phone are optional.
# keyvault_contacts =

# When true (recommended), data-plane access is governed by Azure RBAC
# role assignments, replacing the legacy access-policy model.
# Set to false only when migrating existing vaults that rely on
# access policies and have not yet been converted to RBAC.
# keyvault_enable_rbac_authorization =

# Enable or disable the entire module without removing it.
# keyvault_enabled =

# Allow Azure Virtual Machines to retrieve certificates stored as
# secrets in this Key Vault during VM provisioning or extension runs.
# keyvault_enabled_for_deployment =

# Allow Azure Disk Encryption to retrieve secrets and unwrap keys
# stored in this Key Vault for encrypting VM OS and data disks.
# keyvault_enabled_for_disk_encryption =

# Allow Azure Resource Manager template deployments to retrieve
# secrets from this Key Vault using the reference() function.
# keyvault_enabled_for_template_deployment =

# List of IPv4 addresses or CIDR ranges allowed through the Key Vault
# firewall. Providing any entry sets the network ACL default action
# to "Deny" and bypass to "AzureServices", so only listed ranges and
# trusted Azure services can reach the vault.
# 
# Examples: ["203.0.113.10/32", "198.51.100.0/24"]
# 
# Note: "0.0.0.0/0" permits all public IPs and is not recommended
# for production environments.
# keyvault_firewall_ip_rules =

# List of subnet resource IDs granted access via VNet service
# endpoints. The subnets must have the
# "Microsoft.KeyVault" service endpoint enabled.
# Example: ["/subscriptions/.../subnets/app-subnet"]
# keyvault_firewall_virtual_network_subnet_ids =

# Optional configuration for a Private Endpoint that places the Key
# Vault on a VNet, removing the need for public internet access.
# When provided, consider setting public_network_access_enabled = false.
# 
# Fields:
# - subnet_id:            (required) Resource ID of the target subnet.
#                         The subnet must not have a network policy
#                         that blocks private endpoints.
# - name:                 (optional) Name for the endpoint resource;
#                         defaults to "<vault-name>-pe".
# - connection_name:      (optional) Name for the private service
#                         connection; defaults to "<vault-name>-psc".
# - private_dns_zone_ids: (optional) List of private DNS zone resource
#                         IDs to register the endpoint in, typically
#                         ["...privatelink.vaultcore.azure.net"].
# keyvault_private_endpoint =

# Allow access to the Key Vault over the public internet.
# Set to false when all access is routed through a private endpoint;
# leaving this true while using private endpoints permits both paths.
# keyvault_public_network_access_enabled =

# Prevent permanent deletion of the vault and its objects until the
# soft-delete retention period expires. Once enabled this cannot be
# disabled. Strongly recommended for production workloads.
# keyvault_purge_protection_enabled =

# Map of Azure RBAC role assignments for the Key Vault data plane.
# Applies only when enable_rbac_authorization = true (the default).
# keyvault_role_assignments =

# Pricing tier for the Key Vault.
# - "standard": software-protected keys, suitable for most workloads.
# - "premium":  adds HSM-backed keys for compliance or high-security use.
# keyvault_sku_name =

# Number of days soft-deleted vaults and their contents are retained
# before they can be purged. Accepted range: 7-90 days.
# Microsoft recommends 90 days for production environments.
# keyvault_soft_delete_retention_days =

# Map of tags applied to all resources created by this module.
# Use to enforce organisational tagging policies (e.g. cost centre,
# environment, owner).
# Example: { environment = "production", cost_centre = "platform" }
# keyvault_tags =

# Azure Active Directory tenant ID that owns the Key Vault.
# Defaults to the tenant of the currently authenticated client.
# Override when deploying into a tenant different from the one
# used for authentication.
# keyvault_tenant_id =


