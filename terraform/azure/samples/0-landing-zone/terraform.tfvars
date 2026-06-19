# See the commentary in ./variables.tf for more info.

# These vars are used at least by the vnet module:
vnet_name          = "nbs7-<environment-name>"
vnet_address_space = ["xx.x.x.x/xx"]
# vnet_location            = "your-region" # Uncomment this line and specify a value if you want a different region than the one specified by the default value in ./variables.tf
vnet_resource_group_name = "nbs7-<environment-name>"
vnet_resource_group_id   = "/subscriptions/<your-subscription-id>/resourceGroups/<vnet_resource_group_name>"

# If you change a *_dns_zone_enabled variable below to false, then the corresponding *_domain_name variable below is unused (in which case you do not need to specify a value for it).

# Used by the public-dns-zone module:
public_dns_zone_enabled = true
public_domain_name      = "az.<your_STLT_name>.nbs.com"

# Used by the private-dns-zone module:
private_dns_zone_enabled = true
private_domain_name      = "az.<your_STLT_name>.nbs.internal"
