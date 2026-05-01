module "kafka" {
  source = "../../modules/2_nbs7/hdi-kafka"

  gtwy_password        = var.kafka_gtwy_password
  gtwy_username        = var.kafka_gtwy_username
  kafka_cluster_name   = var.kafka_cluster_name
  kafka_subnet_name    = var.kafka_subnet_name
  location             = var.kafka_location
  password             = var.kafka_password
  sg_name              = var.kafka_sg_name
  storage_account_name = var.kafka_storage_account_name
  username             = var.kafka_username
  vnet_name            = var.kafka_vnet_name
  vnet_rg              = var.kafka_vnet_rg
}

