prefix = "tf-nbs6"
resource_group_name = "cdc-nbs-classic-rg"
vnet_name = "vnet-cdc-nbs-sql-managed-instance"
appgw_subnet_name = "NBS6AppGatewaySubnet"
aci_subnet_name = "NBS6ACISubnet"
aci_ip_list =  ["10.0.1.4", "10.0.1.5", "10.0.1.6"]
quay_nbs6_repository = "quay.io/us-cdcgov/cdc-nbs-modernization/nbs6:6.0.15.1"
sql_database_endpoint = "nbs-sql-managed-instance.a4e769cba908.database.windows.net"