# See the commentary in ./variables.tf for more info.

# These vars are used at least by the vnet module:
vnet_name          = "nbs7-<environment-name>"
vnet_address_space = ["xx.x.x.x/xx"]
# vnet_location            = "your-region" # Uncomment this line and specify a value if you want a different region than the one specified by the default value in ./variables.tf
vnet_resource_group_name = "nbs7-<environment-name>"
vnet_resource_group_id   = "/subscriptions/<your-subscription-id>/resourceGroups/<vnet_resource_group_name>"

# If you change a *_dns_zone_enabled variable below to true, then you need to uncomment the corresponding *_domain_name variable below and set a value for it, otherwise leave the corresponding *_domain_name variable commented out.

# Used by the public-dns-zone module:
public_dns_zone_enabled = false
#public_domain_name = "az.<STLT-name>.nbs.com"

# Used by the private-dns-zone module:
private_dns_zone_enabled = false
#private_domain_name = "az.<STLT-name>.nbs.internal"
