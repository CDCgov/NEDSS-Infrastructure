## remove this block once testing is done.
# provider "azurerm" {
#   features {}
# }

# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = "=3.0.1"
#     }
#   }
# }

#######################################+++++++++#####$$$$$$$$$$%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Kafka HDinsight storage account
resource "azurerm_storage_account" "kafka-storage-account" {
  name                     = "${var.resource_prefix}${var.storage_account_name}" # "hdinsightstor"
  resource_group_name      = data.azurerm_resource_group.rg.name # azurerm_resource_group.kafka-rg.name
  location                 = data.azurerm_resource_group.rg.location #azurerm_resource_group.kafka-rg.location
  account_tier             = var.account_tier # "Standard"
  account_replication_type = var.account_replication_type # "LRS"
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  tags = merge(tomap({"Name"="${var.resource_prefix}-${var.storage_account_name}"}),var.tags)
   lifecycle {
	ignore_changes = [ 
		tags["business_steward"],
		tags["center"],
		tags["environment"],
		tags["escid"],
		tags["funding_source"],
		tags["pii_data"],
		tags["security_compliance"],
		tags["security_steward"],
		tags["support_group"],
		tags["system"],
		tags["technical_poc"],
		tags["technical_steward"],
		tags["zone"]
		]
	}
}

# # Kafka HDinsight storage container
resource "azurerm_storage_container" "hdi-kafka-storage-container" {
  name                  = "${var.resource_prefix}-${var.storage_account_name}-container" 
  storage_account_name  = azurerm_storage_account.kafka-storage-account.name
  container_access_type = var.container_access_type 
}

# # Kafka HDinsight network security group
resource "azurerm_network_security_group" "hdi-kafka-sg" {
  name                = "${var.resource_prefix}-${var.sg_name}"
  location            = data.azurerm_resource_group.rg.location 
  resource_group_name = data.azurerm_resource_group.rg.name 
  tags = merge(tomap({"Name"="${var.resource_prefix}-${var.sg_name}"}),var.tags)
   lifecycle {
	ignore_changes = [ 
		tags["business_steward"],
		tags["center"],
		tags["environment"],
		tags["escid"],
		tags["funding_source"],
		tags["pii_data"],
		tags["security_compliance"],
		tags["security_steward"],
		tags["support_group"],
		tags["system"],
		tags["technical_poc"],
		tags["technical_steward"],
		tags["zone"]
		]
	}
}

resource "azurerm_network_security_rule" "allow_tag_custom_any_inbound_rule" {
  name                        = "AllowTagCustomAnyInbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "HDInsight.EastUS"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.hdi-kafka-sg.name
  resource_group_name         = data.azurerm_resource_group.rg.name
}

##########################################################################

resource "azurerm_subnet_network_security_group_association" "kafka-subnet-sg" {
  subnet_id                 = data.azurerm_subnet.kafka_subnet_name.id
  network_security_group_id = azurerm_network_security_group.hdi-kafka-sg.id
}

resource "azurerm_hdinsight_kafka_cluster" "kafka-cluster" {
  name                = "${var.resource_prefix}-${var.kafka_cluster_name}" 
  depends_on = [azurerm_storage_account.kafka-storage-account, azurerm_storage_container.hdi-kafka-storage-container]
  resource_group_name = data.azurerm_resource_group.rg.name 
  location            = data.azurerm_resource_group.rg.location 
  cluster_version     = var.cluster_version 
  tier                = var.cluster_tier 
  encryption_in_transit_enabled = var.encryption_in_transit_enabled
  tls_min_version = var.tls_min_version
  tags = merge(tomap({"Name"="${var.resource_prefix}-${var.kafka_cluster_name}"}),var.tags)
   lifecycle {
	ignore_changes = [ 
		tags["business_steward"],
		tags["center"],
		tags["environment"],
		tags["escid"],
		tags["funding_source"],
		tags["pii_data"],
		tags["security_compliance"],
		tags["security_steward"],
		tags["support_group"],
		tags["system"],
		tags["technical_poc"],
		tags["technical_steward"],
		tags["zone"]
		]
	}
  component_version {
    kafka = var.component_version
  }

  gateway {
    username = var.gtwy_username 
    password = var.gtwy_password 
  }

  storage_account {
    storage_container_id = azurerm_storage_container.hdi-kafka-storage-container.id
    storage_account_key  = azurerm_storage_account.kafka-storage-account.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = var.head_vm_size 
      username = var.username
      password = var.password
      virtual_network_id = data.azurerm_virtual_network.vnet.id
      subnet_id = data.azurerm_subnet.kafka_subnet_name.id
    }

    worker_node {
      vm_size                  = var.worker_vm_size 
      username                 = var.username
      password                 = var.password
      number_of_disks_per_node = var.number_of_disks_per_node
      target_instance_count    = var.target_instance_count
      virtual_network_id = data.azurerm_virtual_network.vnet.id
      subnet_id = data.azurerm_subnet.kafka_subnet_name.id
    }

    zookeeper_node {
      vm_size  = var.zookeeper_vm_size 
      username = var.username 
      password = var.password 
      virtual_network_id = data.azurerm_virtual_network.vnet.id
      subnet_id = data.azurerm_subnet.kafka_subnet_name.id
    }
  }
}

##################################################################
