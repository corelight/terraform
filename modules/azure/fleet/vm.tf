resource "azurerm_network_interface" "fleet" {
  name                = "${var.deployment_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "fleet-ip-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "fleet" {
  network_interface_id      = azurerm_network_interface.fleet.id
  network_security_group_id = local.nsg_id
}

resource "azurerm_network_interface_backend_address_pool_association" "fleet" {
  network_interface_id    = azurerm_network_interface.fleet.id
  ip_configuration_name   = "fleet-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.fleet.id
}

resource "azurerm_linux_virtual_machine" "fleet" {
  name                = "${var.deployment_name}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  custom_data         = module.fleet_config.cloudinit_config.rendered

  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = var.admin_username
  }

  source_image_id = var.fleet_image_id

  dynamic "source_image_reference" {
    for_each = var.fleet_image_id == null ? [1] : []
    content {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  network_interface_ids = [
    azurerm_network_interface.fleet.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  tags = var.tags
}
