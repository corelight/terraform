# Unit tests for Azure Flow Sensor Example
# These tests validate the example configuration

mock_provider "azurerm" {}

mock_provider "cloudinit" {}

run "verify_default_configuration" {
  command = plan

  variables {
    deployment_name           = "test-flow-sensor"
    resource_group_name       = "test-rg"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7 test@example"
    community_string          = "test-community"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/management"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/monitoring"
    license_key               = "test-license-key"
    storage_account_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testflowlogs"
  }
}

run "verify_with_fleet_integration" {
  command = plan

  variables {
    deployment_name           = "test-flow-sensor"
    resource_group_name       = "test-rg"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7 test@example"
    community_string          = "test-community"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/management"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/monitoring"
    fleet_token               = "test-fleet-token"
    fleet_url                 = "https://fleet.example.com:1443/fleet/v1/internal/softsensor/websocket"
    fleet_server_sslname      = "fleet.example.com"
    storage_account_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testflowlogs"
  }
}

run "verify_with_ssh_restrictions" {
  command = plan

  variables {
    deployment_name                = "test-flow-sensor"
    resource_group_name            = "test-rg"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7 test@example"
    community_string               = "test-community"
    management_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/management"
    monitoring_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/monitoring"
    license_key                    = "test-license-key"
    storage_account_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testflowlogs"
    ssh_allow_cidrs                = ["10.0.0.0/8", "192.168.1.0/24"]
    management_interface_public_ip = true
  }
}
