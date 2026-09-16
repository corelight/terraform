locals {
  sensors = jsondecode(file("${path.module}/sensors.json"))

  tags = merge(var.tags, {
    terraform = "true"
    purpose   = "Corelight"
  })
}

####################################################################################################
# Resource Group
####################################################################################################

resource "azurerm_resource_group" "sensors" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

####################################################################################################
# Networking — subnets in the existing VNet
####################################################################################################

data "azurerm_virtual_network" "existing" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group
}

resource "azurerm_subnet" "management" {
  name                 = "${var.deployment_name}-management-subnet"
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.management_subnet_cidr]
}

resource "azurerm_subnet" "monitoring" {
  name                 = "${var.deployment_name}-monitoring-subnet"
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.monitoring_subnet_cidr]
}

####################################################################################################
# Shared NSGs — one pair for all sensors (instead of per-sensor NSGs)
####################################################################################################

resource "azurerm_network_security_group" "management" {
  name                = "${var.deployment_name}-mgmt-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.sensors.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "mgmt_egress" {
  name                         = "AllowOutbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = ["0.0.0.0/0"]
  resource_group_name          = azurerm_resource_group.sensors.name
  network_security_group_name  = azurerm_network_security_group.management.name
}

resource "azurerm_network_security_rule" "mgmt_ssh" {
  count                       = length(var.ssh_allow_cidrs) > 0 ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_allow_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sensors.name
  network_security_group_name = azurerm_network_security_group.management.name
}

resource "azurerm_network_security_group" "monitoring" {
  name                = "${var.deployment_name}-mon-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.sensors.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "mon_egress" {
  name                         = "AllowOutbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = ["0.0.0.0/0"]
  resource_group_name          = azurerm_resource_group.sensors.name
  network_security_group_name  = azurerm_network_security_group.monitoring.name
}

resource "azurerm_network_security_rule" "mon_vxlan" {
  name                        = "AllowVXLAN"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefixes     = var.monitoring_ingress_allow_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sensors.name
  network_security_group_name = azurerm_network_security_group.monitoring.name
}

resource "azurerm_network_security_rule" "mon_health_check" {
  name                        = "AllowHealthCheck"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "41080"
  source_address_prefixes     = ["168.63.129.16/32"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sensors.name
  network_security_group_name = azurerm_network_security_group.monitoring.name
}

####################################################################################################
# Internal Load Balancer — distributes mirrored traffic across sensors
####################################################################################################

resource "azurerm_lb" "sensors" {
  name                = "${var.deployment_name}-sensor-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.sensors.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "${var.deployment_name}-monitoring"
    subnet_id = azurerm_subnet.monitoring.id
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "monitoring" {
  name            = "${var.deployment_name}-monitoring-pool"
  loadbalancer_id = azurerm_lb.sensors.id
}

resource "azurerm_lb_probe" "sensor_health" {
  name                = "${var.deployment_name}-sensor-health"
  loadbalancer_id     = azurerm_lb.sensors.id
  port                = 41080
  protocol            = "Http"
  request_path        = "/api/system/healthcheck"
  interval_in_seconds = 15
  number_of_probes    = 3
  probe_threshold     = 10
}

resource "azurerm_lb_rule" "vxlan" {
  name                           = "${var.deployment_name}-vxlan"
  loadbalancer_id                = azurerm_lb.sensors.id
  protocol                       = "Udp"
  frontend_port                  = 4789
  backend_port                   = 4789
  frontend_ip_configuration_name = "${var.deployment_name}-monitoring"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.monitoring.id]
  probe_id                       = azurerm_lb_probe.sensor_health.id
}

####################################################################################################
# Sensors — one VM per manifest entry, tokens are stable across image upgrades
####################################################################################################

module "sensors" {
  source   = "../../../modules/azure/sensor-single"
  for_each = local.sensors

  deployment_name           = each.key
  location                  = var.location
  resource_group_name       = azurerm_resource_group.sensors.name
  corelight_sensor_image_id = var.corelight_sensor_image_id
  sensor_ssh_public_key     = var.sensor_ssh_public_key
  community_string          = var.community_string

  management_subnet_id = azurerm_subnet.management.id
  monitoring_subnet_id = azurerm_subnet.monitoring.id

  # Fleet pairing — token from manifest, URL and sslname shared
  fleet_token          = each.value
  fleet_url            = var.fleet_url
  fleet_server_sslname = var.fleet_server_sslname

  # Use shared NSGs instead of per-sensor ones
  management_nsg_id = azurerm_network_security_group.management.id
  monitoring_nsg_id = azurerm_network_security_group.monitoring.id

  virtual_machine_size = var.virtual_machine_size
  os_disk_size_gb      = var.os_disk_size_gb

  # Health check source is the Azure LB probe IP
  health_check_allow_cidrs = ["168.63.129.16/32"]

  tags = local.tags
}

####################################################################################################
# Associate each sensor's monitoring NIC with the ILB backend pool
####################################################################################################

resource "azurerm_network_interface_backend_address_pool_association" "sensor_monitoring" {
  for_each = module.sensors

  network_interface_id    = each.value.monitoring_interface_id
  ip_configuration_name   = "monitoring-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.monitoring.id
}
