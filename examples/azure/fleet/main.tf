locals {
  tags = merge(var.tags, {
    terraform = "true"
    purpose   = "Corelight"
  })
}

resource "azurerm_resource_group" "fleet_rg" {
  location = var.location
  name     = var.resource_group_name
  tags     = local.tags
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group
}

resource "azurerm_subnet" "fleet_subnet" {
  name                 = "${var.deployment_name}-subnet"
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  address_prefixes     = [var.fleet_subnet_cidr]
}

module "fleet" {
  source = "../../../modules/azure/fleet"

  location            = var.location
  resource_group_name = azurerm_resource_group.fleet_rg.name
  subnet_id           = azurerm_subnet.fleet_subnet.id
  deployment_name     = var.deployment_name

  ssh_public_key                 = var.ssh_public_key
  community_string               = var.community_string
  fleet_username                 = var.fleet_username
  fleet_password                 = var.fleet_password
  fleet_certificate_file_path    = var.fleet_certificate_file_path
  fleet_sensor_license_file_path = var.fleet_sensor_license_file_path
  corelight_package_repo_token   = var.corelight_package_repo_token

  vm_size           = var.vm_size
  admin_cidr_blocks = var.admin_cidr_blocks

  dns_zone_name                = var.dns_zone_name
  dns_zone_resource_group_name = var.dns_zone_resource_group_name

  tags = local.tags
}
