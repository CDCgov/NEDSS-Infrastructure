module "agw_public" {
  source = "../../modules/2-nbs7/agw-public"

  agw_aks_ip       = var.agw_aks_ip
  agw_backend_host = var.agw_backend_host

  agw_key_vault_cert_name_public  = var.agw_key_vault_cert_name_public
  agw_key_vault_cert_name_private = var.agw_key_vault_cert_name_private
  agw_key_vault_cert_rg           = var.agw_key_vault_cert_rg
  agw_key_vault_name              = "${var.vnet_resource_group_name}-kv" # Needs to match the value for 'name' in ../0-landing-zone/keyvault.tf

  agw_resource_group_name = var.vnet_resource_group_name
  agw_subnet_name         = var.agw_subnet_name
  agw_vnet_name           = var.vnet_name
  nsg_akamai_ips          = var.agw_nsg_akamai_ips
  resource_prefix         = var.environment_name

  agw_public_hostname  = var.agw_public_hostname
  agw_private_ip       = var.agw_private_ip
  agw_private_hostname = var.agw_private_hostname
}
