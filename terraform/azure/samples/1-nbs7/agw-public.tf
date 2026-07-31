module "agw_public" {
  source = "../../modules/1-nbs7/agw-public"

  enabled         = var.agw_public_enabled
  resource_prefix = var.environment_name

  agw_resource_group_name  = var.vnet_resource_group_name
  agw_vnet_name            = var.vnet_name
  agw_subnet_name          = var.agw_subnet_name
  role_based_kv            = var.agw_role_based_kv
  agw_role_definition_name = var.agw_role_definition_name

  # SSL Certificate Settings
  agw_key_vault_cert_rg           = var.agw_key_vault_cert_rg
  agw_key_vault_name              = "${var.vnet_resource_group_name}-kv" # Needs to match the value for 'name' in ../0-landing-zone/keyvault.tf
  agw_key_vault_cert_name_public  = var.agw_key_vault_cert_name_public
  agw_key_vault_cert_name_private = var.agw_key_vault_cert_name_private

  # Public Gateway Settings
  nsg_akamai_ips           = var.agw_nsg_akamai_ips
  agw_app_public_hostname  = var.agw_app_public_hostname
  agw_data_public_hostname = var.agw_data_public_hostname
  agw_app_backend_host     = var.agw_app_backend_host
  agw_data_backend_host    = var.agw_data_backend_host
  agw_aks_ip               = var.agw_aks_ip

  # Private Gateway Settings
  enable_dual_gateway      = var.agw_enable_dual_gateway
  agw_private_ip           = var.agw_private_ip
  agw_private_hostname     = var.agw_private_hostname
  agw_private_backend_host = var.agw_private_backend_host
  agw_nbs_ip_private       = var.agw_nbs_ip_private
}
