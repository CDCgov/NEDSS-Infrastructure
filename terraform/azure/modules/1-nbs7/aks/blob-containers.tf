resource "azurerm_storage_container" "data_compare" {
  count                 = var.create_datacompare_resources ? 1 : 0
  name                  = "${var.resource_prefix}-data-compare"
  storage_account_id    = data.azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "otel_collector" {
  count                 = var.create_otel_collector_resources ? 1 : 0
  name                  = "${var.resource_prefix}-otel-collector"
  storage_account_id    = data.azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

