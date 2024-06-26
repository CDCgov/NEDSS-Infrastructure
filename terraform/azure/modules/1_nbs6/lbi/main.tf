# Create Internal Load Balancer for NBS6 Container with Static IP
resource "azurerm_lb" "lbi" {
  name                = "${var.resource_prefix}-lbi"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "${var.resource_prefix}-lbi-frontend-ip-configuration"
    private_ip_address   = "${var.lbi_private_ip}"
    private_ip_address_version = "IPv4"
    subnet_id            = data.azurerm_subnet.lbi_subnet.id
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

# Create Backend Pool
resource "azurerm_lb_backend_address_pool" "lbi-pool" {
  depends_on = [ azurerm_lb.lbi ]
  name            = "${var.resource_prefix}-lbi-backend-pool"
  loadbalancer_id = azurerm_lb.lbi.id
}

# Add 1st Static IP for ACI
resource "azurerm_lb_backend_address_pool_address" "lbi-pool-address-0" {
  depends_on = [ azurerm_lb_backend_address_pool.lbi-pool ]
  name                    = "${var.resource_prefix}-lbi-address-0"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbi-pool.id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = "${var.lbi_aci_ip_list[0]}"
}

# Add 2nd Static IP for ACI
resource "azurerm_lb_backend_address_pool_address" "lbi-pool-address-1" {
  depends_on = [ azurerm_lb_backend_address_pool.lbi-pool ]
  name                    = "${var.resource_prefix}-lbi-address-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbi-pool.id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = "${var.lbi_aci_ip_list[1]}"
}

# Add 3rd Static IP for ACI
resource "azurerm_lb_backend_address_pool_address" "lbi-pool-address-2" {
  depends_on = [ azurerm_lb_backend_address_pool.lbi-pool ]
  name                    = "${var.resource_prefix}-lbi-address-2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbi-pool.id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = "${var.lbi_aci_ip_list[2]}"
}

# Configure Health Check
resource "azurerm_lb_probe" "lbi-probe" {
  depends_on = [ azurerm_lb.lbi ]
  loadbalancer_id     = azurerm_lb.lbi.id
  name                = "${var.resource_prefix}-lbi-probe"
  port                = 7001
  protocol            = "Tcp"
}

# Configure Load Balancer Rule
resource "azurerm_lb_rule" "lbi-rule" {
  depends_on = [ azurerm_lb.lbi ]
  loadbalancer_id                = azurerm_lb.lbi.id
  name                           = "${var.resource_prefix}-lbi-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 7001
  frontend_ip_configuration_name = azurerm_lb.lbi.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbi-pool.id]
  probe_id                       = azurerm_lb_probe.lbi-probe.id
}
