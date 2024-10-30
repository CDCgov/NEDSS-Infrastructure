### Deploy NBS6 in ACI ###

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aci_log" {
  name                = "${var.resource_prefix}-aci-log"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 60
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

# Create NBS6 Container Group
resource "azurerm_container_group" "aci" {
  depends_on          = [ azurerm_log_analytics_workspace.aci_log ]
  name                = "${var.resource_prefix}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Windows"
  ip_address_type     = "Private"
  subnet_ids          = toset([data.azurerm_subnet.aci_subnet.id])

 dynamic identity {
    for_each = var.aci_use_private_acr ? [1] : []
    content {
      type = "UserAssigned"
      identity_ids = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
    }
  }

  dynamic image_registry_credential {
    for_each = var.aci_use_private_acr ? [1] : []
    content {
      user_assigned_identity_id = data.azurerm_user_assigned_identity.user_assigned_identity.id
      server = var.aci_private_acr_server_url
    }
  }

  container {
    name   = "${var.resource_prefix}-container"
    image  = var.aci_nbs6_repository
    cpu    = var.aci_cpu
    memory = var.aci_memory
    ports {
      port     = 7001
      protocol = "TCP"
    }

    ports {
      port     = 2323
      protocol = "TCP"
    }

    ports {
      port     = 4447
      protocol = "TCP"
    }

    environment_variables = {
      DATABASE_ENDPOINT = data.azurerm_mssql_managed_instance.sqlmi_endpoint.fqdn
      GITHUB_RELEASE_TAG = var.aci_github_release_tag
    }

    volume {
      name = "${var.resource_prefix}-log"
      mount_path = "C:\\wildfly-10.0.0.Final\\nedssdomain\\log"
      empty_dir = true
    }

  }

  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.aci_log.workspace_id
      workspace_key = azurerm_log_analytics_workspace.aci_log.primary_shared_key
    }
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

# Create Log Analytics Workspace for SAS
resource "azurerm_log_analytics_workspace" "sas_aci_log" {
  name                = "${var.resource_prefix}-sas-aci-log"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 60
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

# Create SAS9.4 Container Group
resource "azurerm_container_group" "sas_aci" {
  depends_on          = [ azurerm_log_analytics_workspace.sas_aci_log ]
  name                = "${var.resource_prefix}-sas-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = toset([data.azurerm_subnet.aci_subnet.id])

 dynamic identity {
    for_each = var.aci_sas_use_private_acr ? [1] : []
    content {
      type = "UserAssigned"
      identity_ids = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
    }
  }

  dynamic image_registry_credential {
    for_each = var.aci_sas_use_private_acr ? [1] : []
    content {
      user_assigned_identity_id = data.azurerm_user_assigned_identity.user_assigned_identity.id
      server = var.aci_private_acr_server_url
    }
  }

  container {
    name   = "${var.resource_prefix}-sas-container"
    image  = var.aci_sas_repository
    cpu    = var.aci_sas_cpu
    memory = var.aci_sas_memory
    ports {
      port     = 2323
      protocol = "TCP"
    }

    environment_variables = {
      db_host = data.azurerm_mssql_managed_instance.sqlmi_endpoint.fqdn
      rdb_user = var.rdb_user
      odse_user = var.odse_user
      db_trace_on = var.db_trace_on
      update_database = var.update_database
      PHCMartETL_cron_schedule = var.phcmartetl_cron_schedule
      MasterEtl_cron_schedule = var.masteretl_cron_schedule
    }

    secure_environment_variables = {
      rdb_pass = var.rdb_pass
      rdb_pass = var.odse_pass
      sas_user_pass = var.sas_user_pass
    }
  }

  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.sas_aci_log.workspace_id
      workspace_key = azurerm_log_analytics_workspace.sas_aci_log.primary_shared_key
    }
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