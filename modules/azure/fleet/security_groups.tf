locals {
  nsg_id = var.nsg_id != "" ? var.nsg_id : azurerm_network_security_group.fleet[0].id
}

resource "azurerm_network_security_group" "fleet" {
  count               = var.nsg_id == "" ? 1 : 0
  name                = "${var.deployment_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "egress" {
  count                       = var.nsg_id == "" ? 1 : 0
  name                        = "AllowOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fleet[0].name
}

resource "azurerm_network_security_rule" "https_ingress" {
  count                       = var.nsg_id == "" ? 1 : 0
  name                        = "AllowHTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = var.https_ingress_cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fleet[0].name
}

resource "azurerm_network_security_rule" "api_ingress" {
  count                       = var.nsg_id == "" ? 1 : 0
  name                        = "AllowFleetAPI"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1443"
  source_address_prefixes     = var.api_ingress_cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fleet[0].name
}

resource "azurerm_network_security_rule" "ssh_ingress" {
  count                       = var.nsg_id == "" && length(var.admin_cidr_blocks) > 0 ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.admin_cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fleet[0].name
}
