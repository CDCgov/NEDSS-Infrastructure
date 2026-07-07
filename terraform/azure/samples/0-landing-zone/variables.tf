
# The "vnet_*" variables below are used by the Virtual network (VNet) in Azure that is provisioned by this Terraform layer.

# For "vnet_name" and "vnet_resource_group_name" it is recommended:
#  * that you specify a value of "nbs7-<environment-name>", 
#  * or if there is more than one STLT using your Azure subscription then specify "nbs7-<STLT-name>-<environment-name>".

variable "vnet_name" {
  type        = string
  description = "The name that will be given to your VNet"
}
variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
  # For guidance on determining what value to set for this variable, please search for "address space" on the following pages:
  #  * https://learn.microsoft.com/en-us/azure/virtual-network/concepts-and-best-practices
  #  * https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq
}
variable "vnet_location" {
  type        = string
  description = "The Programmatic name (from https://learn.microsoft.com/en-us/azure/reliability/regions-list) of the Azure region where you want your VNet to be provisioned."
  default     = "eastus"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "The name of the Resource group that you have already created in your Azure subscription for the NBS 7 environment that this Terraform layer provisions."
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id."
}

variable "private_dns_zone_enabled" {
  type        = bool
  description = "Whether Terraform should provision the Private DNS zone"
  default     = true # In your ./terraform.tfvars set this variable to false if you already have a private DNS zone that you will use for this environment.
}
variable "private_domain_name" {
  type        = string
  description = "The name of the Private DNS zone (if one is to be provisioned by Terraform)"
  default     = ""
}

variable "public_dns_zone_enabled" {
  type        = bool
  description = "Whether Terraform should provision the public DNS zone"
  default     = true
}
variable "public_domain_name" {
  type        = string
  description = "The name of the public DNS zone (if one is to be provisioned by Terraform)"
  default     = ""
}

variable "keyvault_firewall_ip_rules" {
  type    = list(string)
  default = []
}

variable "keyvault_role_assignments" {
  type = map(object({
    principal_id   = string
    role           = string
    principal_type = optional(string)
    description    = optional(string)
  }))
  default = {}
}

variable "subnet__public_gateways__address_prefixes" {
  type = list(string)
}
variable "subnet__aks__address_prefixes" {
  type = list(string)
}
variable "subnet__hdikafka__address_prefixes" {
  type = list(string)
}
variable "subnet__endpoint__address_prefixes" {
  type = list(string)
}
