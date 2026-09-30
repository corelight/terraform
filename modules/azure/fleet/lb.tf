resource "azurerm_public_ip" "fleet" {
  name                = "${var.deployment_name}-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "fleet" {
  name                = "${var.deployment_name}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.deployment_name}-frontend"
    public_ip_address_id = azurerm_public_ip.fleet.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "fleet" {
  name            = "${var.deployment_name}-backend-pool"
  loadbalancer_id = azurerm_lb.fleet.id
}

resource "azurerm_lb_probe" "https" {
  name                = "${var.deployment_name}-https-probe"
  loadbalancer_id     = azurerm_lb.fleet.id
  protocol            = "Tcp"
  port                = 443
  interval_in_seconds = 15
}

resource "azurerm_lb_probe" "api" {
  name                = "${var.deployment_name}-api-probe"
  loadbalancer_id     = azurerm_lb.fleet.id
  protocol            = "Tcp"
  port                = 1443
  interval_in_seconds = 15
}

resource "azurerm_lb_rule" "https" {
  name                           = "${var.deployment_name}-https-rule"
  loadbalancer_id                = azurerm_lb.fleet.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.deployment_name}-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fleet.id]
  probe_id                       = azurerm_lb_probe.https.id
  idle_timeout_in_minutes        = 15
  tcp_reset_enabled              = true
}

resource "azurerm_lb_rule" "api" {
  name                           = "${var.deployment_name}-api-rule"
  loadbalancer_id                = azurerm_lb.fleet.id
  protocol                       = "Tcp"
  frontend_port                  = 1443
  backend_port                   = 1443
  frontend_ip_configuration_name = "${var.deployment_name}-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fleet.id]
  probe_id                       = azurerm_lb_probe.api.id
  idle_timeout_in_minutes        = 15
  tcp_reset_enabled              = true
}
