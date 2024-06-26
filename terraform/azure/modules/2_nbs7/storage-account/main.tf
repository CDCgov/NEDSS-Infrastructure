data "azurerm_resource_group" "main" {
  name                = var.resource_group_name 
}

data "azurerm_subnet" "endpoint" {
  name = var.subnet_name
  resource_group_name = var.resource_group_name 
  virtual_network_name = var.virtual_network_name
}

# create storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind = var.account_kind
  enable_https_traffic_only = true
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.blob_container_delete_retention_days
    }

    
  }
}

#Azure Blob endpoint 
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.storage_account_name}-blob"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.endpoint.id
 
  private_service_connection {
    name                           = "${var.storage_account_name}-blob-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  ip_configuration {
    name = "${var.storage_account_name}-blob-ipconfig"
    member_name = "blob"
    subresource_name = "blob"
    private_ip_address = var.blob_private_ip_address
  }
 
  dynamic private_dns_zone_group {
    for_each = var.create_dns_record ? ["apply"] : []
    content {
      name                 = "${var.storage_account_name}-blob-zone-group"
      private_dns_zone_ids = [var.dns_zone_id_blob]
      
    }    
  }
 
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
 
# resource "azurerm_private_dns_a_record" "blob" {
#   name                = "${var.storage_account_name}-blob"
#   zone_name           = var.dns_zone_name_blob
#   resource_group_name = data.azurerm_resource_group.main.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.blob.private_service_connection.0.private_ip_address]
# }

# Azure Files endpoint
resource "azurerm_private_endpoint" "file" {
  name                = "${var.storage_account_name}-file"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.endpoint.id  
 
  private_service_connection {
    name                           = "${var.storage_account_name}-file-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  ip_configuration {
    name = "${var.storage_account_name}-file-ipconfig"
    member_name = "file"
    subresource_name = "file"
    private_ip_address = var.file_private_ip_address
  }
 
  dynamic private_dns_zone_group {
    for_each = var.create_dns_record ? ["apply"] : []
    content {
      name                 = "${var.storage_account_name}-file-zone-group"
      private_dns_zone_ids = [var.dns_zone_id_file]
      
    }    
  }
 
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
 
# resource "azurerm_private_dns_a_record" "file" {
#   name                = "${var.storage_account_name}-file"
#   zone_name           = var.dns_zone_name_file
#   resource_group_name = data.azurerm_resource_group.main.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.file.private_service_connection.0.private_ip_address]
# }


 
