module "agw_public" {
  source = "../../modules/0_landing_zone/agw-public"

  agw_aks_ip              = var.agw_aks_ip
  agw_backend_host        = var.agw_backend_host
  agw_key_vault_cert_name = var.agw_key_vault_cert_name
  agw_key_vault_cert_rg   = var.agw_key_vault_cert_rg
  agw_key_vault_name      = var.agw_key_vault_name
  agw_resource_group_name = var.agw_resource_group_name
  agw_subnet_name         = var.agw_subnet_name
  agw_vnet_name           = var.agw_vnet_name
  nsg_akamai_ips          = var.nsg_akamai_ips
  resource_prefix         = var.resource_prefix

}
