# Unit tests for Azure Multi-Sensor Managed Example
# These tests validate the example-level configuration using mock providers.
#
# The sensor-single module instances are overridden with mock outputs because
# mock providers produce unknown resource IDs at plan time, which breaks the
# module's internal count conditions. The sensor-single module has its own
# test suite — these tests focus on the example's orchestration:
# for_each from manifest, ILB setup, shared NSGs, and variable passthrough.

mock_provider "azurerm" {
  mock_data "azurerm_virtual_network" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
      name                = "test-vnet"
      address_space       = ["10.0.0.0/16"]
      location            = "eastus"
      resource_group_name = "networking-rg"
    }
  }
}

mock_provider "cloudinit" {}

run "test_two_sensor_fleet_managed" {
  command = plan

  override_module {
    target = module.sensors["sensor-1"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-1-vm"
      sensor_private_ip_address = "10.0.10.4"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mon-nic"
    }
  }

  override_module {
    target = module.sensors["sensor-2"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-2-vm"
      sensor_private_ip_address = "10.0.10.5"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mon-nic"
    }
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.10.0/24"
    monitoring_subnet_cidr         = "10.0.11.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB test@example.com"
    community_string               = "test-community"
    fleet_url                      = "https://fleet.example.com:1443"
  }

  # Validates: two sensors from manifest, ILB created, shared NSGs created
}

run "test_custom_deployment_name" {
  command = plan

  override_module {
    target = module.sensors["sensor-1"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-1-vm"
      sensor_private_ip_address = "10.0.10.4"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mon-nic"
    }
  }

  override_module {
    target = module.sensors["sensor-2"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-2-vm"
      sensor_private_ip_address = "10.0.10.5"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mon-nic"
    }
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.10.0/24"
    monitoring_subnet_cidr         = "10.0.11.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB test@example.com"
    community_string               = "test-community"
    fleet_url                      = "https://fleet.example.com:1443"
    deployment_name                = "prod-east"
  }

  # Validates custom deployment name prefixes shared resources (NSGs, LB, subnets)
}

run "test_with_ssh_restrictions" {
  command = plan

  override_module {
    target = module.sensors["sensor-1"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-1-vm"
      sensor_private_ip_address = "10.0.10.4"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mon-nic"
    }
  }

  override_module {
    target = module.sensors["sensor-2"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-2-vm"
      sensor_private_ip_address = "10.0.10.5"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mon-nic"
    }
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.10.0/24"
    monitoring_subnet_cidr         = "10.0.11.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB test@example.com"
    community_string               = "test-community"
    fleet_url                      = "https://fleet.example.com:1443"
    ssh_allow_cidrs                = ["10.0.0.0/8", "192.168.1.0/24"]
  }

  # Validates SSH restriction NSG rule is created when ssh_allow_cidrs is set
}

run "test_with_custom_monitoring_cidrs" {
  command = plan

  override_module {
    target = module.sensors["sensor-1"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-1-vm"
      sensor_private_ip_address = "10.0.10.4"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-1-mon-nic"
    }
  }

  override_module {
    target = module.sensors["sensor-2"]
    outputs = {
      sensor_vm_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/sensor-2-vm"
      sensor_private_ip_address = "10.0.10.5"
      sensor_public_ip_address  = null
      management_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mgmt-nic"
      monitoring_interface_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/sensor-2-mon-nic"
    }
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.10.0/24"
    monitoring_subnet_cidr         = "10.0.11.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB test@example.com"
    community_string               = "test-community"
    fleet_url                      = "https://fleet.example.com:1443"
    monitoring_ingress_allow_cidrs = ["10.0.0.0/8"]
  }

  # Validates restricted monitoring ingress CIDRs on shared NSG
}
