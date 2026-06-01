# Unit tests for Azure Sensor Scale Set Module
# These tests validate the module directly

mock_provider "azurerm" {
  mock_data "azurerm_subnet" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
      name                 = "test-subnet"
      address_prefix       = "10.0.1.0/24"
      address_prefixes     = ["10.0.1.0/24"]
      resource_group_name  = "test-rg"
      virtual_network_name = "test-vnet"
    }
  }
}

mock_provider "cloudinit" {}

run "test_minimal_configuration" {
  command = plan

  variables {
    location                  = "eastus"
    resource_group_name       = "test-rg"
    license_key               = "test-license-key"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    community_string          = "test-community"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
  }

  # Validates minimal required configuration works
}

run "test_with_fleet_proxy_configuration" {
  command = plan

  variables {
    location                  = "eastus"
    resource_group_name       = "test-rg"
    license_key               = "test-license-key"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    community_string          = "test-community"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
    fleet_http_proxy          = "http://proxy:8080"
    fleet_https_proxy         = "https://proxy:8443"
  }

  # Validates Fleet integration with proxy configuration
}

run "test_custom_resource_names" {
  command = plan

  variables {
    location                  = "eastus"
    resource_group_name       = "test-rg"
    license_key               = "test-license-key"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    community_string          = "test-community"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
    scale_set_name            = "custom-scale-set"
    load_balancer_name        = "custom-lb"
    nat_gateway_name          = "custom-nat-gw"
    autoscale_setting_name    = "custom-autoscale"
  }

  # Validates custom resource naming
}

run "test_with_fedramp_and_prometheus" {
  command = plan

  variables {
    location                  = "eastus"
    resource_group_name       = "test-rg"
    license_key               = "test-license-key"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    community_string          = "test-community"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
    fedramp_mode_enabled      = true
    prometheus_enabled        = true
  }

  # Validates FedRAMP and Prometheus configuration
}

run "test_custom_vm_configuration" {
  command = plan

  variables {
    location                     = "eastus"
    resource_group_name          = "test-rg"
    license_key                  = "test-license-key"
    management_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
    corelight_sensor_image_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    community_string             = "test-community"
    sensor_ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    fleet_token                  = "test-token"
    fleet_url                    = "https://fleet.example.com"
    fleet_server_sslname         = "fleet.example.com"
    virtual_machine_size         = "Standard_D8s_v3"
    virtual_machine_os_disk_size = 1000
    sensor_admin_username        = "adminuser"
  }

  # Validates custom VM configuration
}


