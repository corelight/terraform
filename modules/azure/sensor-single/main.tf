resource "azurerm_network_security_group" "management" {
  count               = var.management_nsg_id == "" ? 1 : 0
  name                = "${var.deployment_name}-mgmt-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "monitoring" {
  count               = var.monitoring_nsg_id == "" ? 1 : 0
  name                = "${var.deployment_name}-mon-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "mgmt_egress" {
  count                       = var.management_nsg_id == "" ? 1 : 0
  name                        = "AllowOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefixes = var.egress_allow_cidrs
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management[0].name
}

resource "azurerm_network_security_rule" "mgmt_ssh_ingress" {
  count                       = var.management_nsg_id == "" && length(var.ssh_allow_cidrs) > 0 ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_allow_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management[0].name
}

resource "azurerm_network_security_rule" "mon_egress" {
  count                       = var.monitoring_nsg_id == "" ? 1 : 0
  name                        = "AllowOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefixes = var.egress_allow_cidrs
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring[0].name
}

resource "azurerm_network_security_rule" "mon_vxlan_ingress" {
  count                       = var.monitoring_nsg_id == "" ? 1 : 0
  name                        = "AllowVXLAN"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefixes     = var.monitoring_ingress_allow_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring[0].name
}

resource "azurerm_network_security_rule" "mon_health_check_ingress" {
  count                       = var.monitoring_nsg_id == "" ? 1 : 0
  name                        = "AllowHealthCheck"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "41080"
  source_address_prefixes     = var.health_check_allow_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring[0].name
}

resource "azurerm_network_interface" "management" {
  name                = "${var.deployment_name}-mgmt-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "management-ip-config"
    subnet_id                     = var.management_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.management_interface_public_ip ? azurerm_public_ip.management[0].id : null
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "management" {
  network_interface_id      = azurerm_network_interface.management.id
  network_security_group_id = var.management_nsg_id == "" ? azurerm_network_security_group.management[0].id : var.management_nsg_id
}

resource "azurerm_public_ip" "management" {
  count               = var.management_interface_public_ip ? 1 : 0
  name                = "${var.deployment_name}-mgmt-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "monitoring" {
  name                          = "${var.deployment_name}-mon-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "monitoring-ip-config"
    subnet_id                     = var.monitoring_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "monitoring" {
  network_interface_id      = azurerm_network_interface.monitoring.id
  network_security_group_id = var.monitoring_nsg_id == "" ? azurerm_network_security_group.monitoring[0].id : var.monitoring_nsg_id
}

module "sensor_config" {
  count  = var.custom_sensor_user_data == "" ? 1 : 0
  source = "../../_shared/config/sensor"

  fleet_community_string           = var.community_string
  sensor_license                   = var.license_key
  fleet_token                      = var.fleet_token
  fleet_url                        = var.fleet_url
  fleet_server_sslname             = var.fleet_server_sslname
  fleet_http_proxy                 = var.fleet_http_proxy
  fleet_https_proxy                = var.fleet_https_proxy
  fleet_no_proxy                   = var.fleet_no_proxy
  sensor_management_interface_name = "eth0"
  sensor_monitoring_interface_name = "eth1"
  base64_encode_config             = true
}

resource "azurerm_linux_virtual_machine" "sensor" {
  name                = "${var.deployment_name}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.virtual_machine_size
  admin_username      = var.sensor_admin_username

  admin_ssh_key {
    public_key = var.sensor_ssh_public_key
    username   = var.sensor_admin_username
  }

  source_image_id = var.corelight_sensor_image_id
  custom_data     = var.custom_sensor_user_data == "" ? module.sensor_config[0].cloudinit_config.rendered : var.custom_sensor_user_data

  network_interface_ids = [
    azurerm_network_interface.management.id,
    azurerm_network_interface.monitoring.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }

  tags = var.tags
}
