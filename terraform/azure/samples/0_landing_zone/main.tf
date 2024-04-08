# Application Gateway for AKS Public Loadbalancer
module nbs7-agw-public {
    source = "../../modules/0_landing_zone/agw-public"
    resource_prefix = var.resource_prefix
    agw_resource_group_name = var.agw_resource_group_name
    agw_vnet_name = var.agw_vnet_name
    agw_subnet_name = var.agw_subnet_name
    agw_key_vault_name = var.agw_key_vault_name
    agw_key_vault_cert_name = var.agw_key_vault_cert_name
    agw_backend_host = var.agw_backend_host
    agw_aks_ip = var.agw_aks_ip
}