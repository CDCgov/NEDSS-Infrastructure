module "kafka" {
  source = "../../modules/2_nbs7/hdi-kafka"

  gtwy_password        = var.gtwy_password
  gtwy_username        = var.gtwy_username
  kafka_cluster_name   = var.kafka_cluster_name
  kafka_subnet_name    = var.kafka_subnet_name
  location             = var.location
  password             = var.password
  sg_name              = var.sg_name
  storage_account_name = var.storage_account_name
  username             = var.username
  vnet_name            = var.vnet_name
  vnet_rg              = var.vnet_rg
}

