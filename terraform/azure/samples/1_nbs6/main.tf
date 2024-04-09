module nbs6-aci{
    source = "../../modules/1_nbs6/aci"
    resource_prefix = var.resource_prefix
    aci_resource_group_name = var.aci_resource_group_name
    aci_vnet_name = var.aci_vnet_name
    aci_subnet_name = var.aci_subnet_name
    aci_quay_nbs6_repository = var.aci_quay_nbs6_repository
    aci_sql_database_endpoint = var.aci_sql_database_endpoint
    aci_cpu = var.aci_cpu
    aci_memory = var.aci_memory
}

module nbs6-agw-private{
    source = "../../modules/1_nbs6/agw-private"
    resource_prefix = var.resource_prefix
    agw_resource_group_name = var.agw_resource_group_name
    agw_vnet_name = var.agw_vnet_name
    agw_subnet_name = var.agw_subnet_name
    agw_key_vault_name = var.agw_key_vault_name
    agw_key_vault_cert_name = var.agw_key_vault_cert_name
    agw_backend_host = var.agw_backend_host
    agw_aci_ip = var.agw_aci_ip
    agw_private_ip = var.agw_private_ip
}

module nbs6-sqlmi{
    source = "../../modules/1_nbs6/sqlmi"
    resource_prefix = var.resource_prefix
    sqlmi_resource_group_name = var.sqlmi_resource_group_name
    sqlmi_vnet_name = var.sqlmi_vnet_name
    sqlmi_subnet_name = var.sqlmi_subnet_name
    sqlmi_key_vault = var.sqlmi_key_vault
    sqlmi_restoring_from_database_name = var.sqlmi_restoring_from_database_name
    sqlmi_restoring_from_database_rg = var.sqlmi_restoring_from_database_rg
    sqlmi_restore_point_in_time = var.sqlmi_restore_point_in_time
    sqlmi_vcore = var.sqlmi_vcore
    sqlmi_storage = var.sqlmi_storage
    sqlmi_sku_name = var.sqlmi_sku_name
}
