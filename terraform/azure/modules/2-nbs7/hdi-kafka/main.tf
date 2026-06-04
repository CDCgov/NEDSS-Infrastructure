# Kafka HDinsight storage account
resource "azurerm_storage_account" "kafka_storage_account" {
  count                             = var.enabled ? 1 : 0
  name                              = "${var.resource_prefix}${var.storage_account_name}" # "hdinsightstor"
  resource_group_name               = data.azurerm_resource_group.rg.name                 # azurerm_resource_group.kafka_rg.name
  location                          = data.azurerm_resource_group.rg.location             #azurerm_resource_group.kafka_rg.location
  account_tier                      = var.account_tier                                    # "Standard"
  account_replication_type          = var.account_replication_type                        # "LRS"
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  tags                              = merge(tomap({ "Name" = "${var.resource_prefix}-${var.storage_account_name}" }), var.tags)

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

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
resource "azurerm_storage_container" "hdi_kafka_storage_container" {
  count                 = var.enabled ? 1 : 0
  name                  = "${var.resource_prefix}-hdinsight-kafka-cluster-data"
  storage_account_name  = azurerm_storage_account.kafka_storage_account[count.index].name
  container_access_type = var.container_access_type
}

# # Kafka HDinsight network security group
resource "azurerm_network_security_group" "hdi_kafka_sg" {
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-${var.sg_name}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = merge(tomap({ "Name" = "${var.resource_prefix}-${var.sg_name}" }), var.tags)
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
  count                       = var.enabled ? 1 : 0
  name                        = "AllowTagCustomAnyInbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "HDInsight.EastUS"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.hdi_kafka_sg[count.index].name
  resource_group_name         = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_hdinsight_outbound" {
  count                       = var.enabled ? 1 : 0
  name                        = "AllowHDInsightOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  network_security_group_name = azurerm_network_security_group.hdi_kafka_sg[count.index].name
  resource_group_name         = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_hdinsight_outbound_80" {
  count                       = var.enabled ? 1 : 0
  name                        = "AllowHDInsightOutbound80"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  network_security_group_name = azurerm_network_security_group.hdi_kafka_sg[count.index].name
  resource_group_name         = data.azurerm_resource_group.rg.name
}


##########################################################################

resource "azurerm_subnet_network_security_group_association" "kafka_subnet_sg" {
  count                     = var.enabled ? 1 : 0
  subnet_id                 = data.azurerm_subnet.kafka_subnet_name.id
  network_security_group_id = azurerm_network_security_group.hdi_kafka_sg[count.index].id
}

resource "azurerm_hdinsight_kafka_cluster" "kafka_cluster" {
  count                         = var.enabled ? 1 : 0
  name                          = "${var.resource_prefix}-${var.kafka_cluster_name}"
  depends_on                    = [azurerm_storage_account.kafka_storage_account, azurerm_storage_container.hdi_kafka_storage_container]
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  cluster_version               = var.cluster_version
  tier                          = var.cluster_tier
  encryption_in_transit_enabled = var.encryption_in_transit_enabled
  tls_min_version               = var.tls_min_version
  tags                          = merge(tomap({ "Name" = "${var.resource_prefix}-${var.kafka_cluster_name}" }), var.tags)
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

  network {
    connection_direction = "Outbound"
    private_link_enabled = true
  }

  gateway {
    username = var.gtwy_username
    password = var.gtwy_password
  }

  private_link_configuration {
    name     = "kafka-private-link"
    group_id = "gateway"

    ip_configuration {
      name                         = "kafka-privatelink-ipconfig"
      primary                      = true
      private_ip_allocation_method = "dynamic"
      subnet_id                    = data.azurerm_subnet.kafka_subnet_name.id
    }
  }

  storage_account {
    storage_resource_id  = azurerm_storage_account.kafka_storage_account[count.index].id
    storage_container_id = azurerm_storage_container.hdi_kafka_storage_container[count.index].id
    storage_account_key  = azurerm_storage_account.kafka_storage_account[count.index].primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size            = var.head_vm_size
      username           = var.username
      password           = var.password
      virtual_network_id = data.azurerm_virtual_network.vnet.id
      subnet_id          = data.azurerm_subnet.kafka_subnet_name.id
    }

    worker_node {
      vm_size                  = var.worker_vm_size
      username                 = var.username
      password                 = var.password
      number_of_disks_per_node = var.number_of_disks_per_node
      target_instance_count    = var.target_instance_count
      virtual_network_id       = data.azurerm_virtual_network.vnet.id
      subnet_id                = data.azurerm_subnet.kafka_subnet_name.id
    }

    zookeeper_node {
      vm_size            = var.zookeeper_vm_size
      username           = var.username
      password           = var.password
      virtual_network_id = data.azurerm_virtual_network.vnet.id
      subnet_id          = data.azurerm_subnet.kafka_subnet_name.id
    }
  }
}

resource "azurerm_private_endpoint" "kafka_private_endpoint" {
  count               = var.enabled ? 1 : 0
  name                = "${var.resource_prefix}-kafka-pe"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.kafka_subnet_name.id

  private_service_connection {
    name                           = "kafka-privatelink-connection"
    private_connection_resource_id = azurerm_hdinsight_kafka_cluster.kafka_cluster[count.index].id
    is_manual_connection           = false

    subresource_names = ["gateway"]
  }
}


##################################################################

resource "azurerm_public_ip" "nat" {
  count               = var.enabled && var.nat_gateway_enabled ? 1 : 0
  name                = "${var.resource_prefix}-nat"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard" # Must be Standard to work with Standard LB/NAT GW
}

resource "azurerm_nat_gateway" "kafka_nat_gw" {
  count                   = var.enabled && var.nat_gateway_enabled ? 1 : 0
  name                    = "${var.resource_prefix}-kafka-nat-gw"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  count                = var.enabled && var.nat_gateway_enabled ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.kafka_nat_gw[count.index].id
  public_ip_address_id = azurerm_public_ip.nat[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "kafka_subnet_nat_assoc" {
  count          = var.enabled && var.nat_gateway_enabled ? 1 : 0
  subnet_id      = data.azurerm_subnet.kafka_subnet_name.id
  nat_gateway_id = azurerm_nat_gateway.kafka_nat_gw[count.index].id
}
