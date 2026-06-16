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
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
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
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
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
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    management_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/management"
    monitoring_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/monitoring"
    license_key                    = "test-license-key"
    storage_account_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testflowlogs"
    ssh_allow_cidrs                = ["10.0.0.0/8", "192.168.1.0/24"]
    management_interface_public_ip = true
  }
}
