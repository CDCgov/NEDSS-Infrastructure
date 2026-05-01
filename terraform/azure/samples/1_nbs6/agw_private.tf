module "nbs6-agw-private" {
  source = "../../modules/1_nbs6/agw-private"

  resource_prefix         = var.agw_resource_prefix
  agw_resource_group_name = var.agw_resource_group_name
  agw_vnet_name           = var.agw_vnet_name
  agw_subnet_name         = var.agw_subnet_name
  agw_key_vault_name      = var.agw_key_vault_name
  agw_key_vault_cert_name = var.agw_key_vault_cert_name
  agw_backend_host        = var.agw_backend_host
  agw_aci_ip              = var.agw_aci_ip
  agw_private_ip          = var.agw_private_ip
  agw_key_vault_cert_rg   = var.agw_key_vault_cert_rg
}
