# Unit tests for Azure Sensor Auto-Scaling Example
# These tests validate the example configuration

mock_provider "azurerm" {
  mock_data "azurerm_virtual_network" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
      name                = "test-vnet"
      address_space       = ["10.0.0.0/16"]
      location            = "eastus"
      resource_group_name = "test-rg"
    }
  }

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
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.1.0/24"
    monitoring_subnet_cidr         = "10.0.2.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    license_key                    = "test-license-key"
  }

  # Validates minimal required configuration works
}

run "test_with_fleet_configuration" {
  command = plan

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.1.0/24"
    monitoring_subnet_cidr         = "10.0.2.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_token                    = "test-token"
    fleet_url                      = "https://fleet.example.com"
    fleet_server_sslname           = "fleet.example.com"
  }

  # Validates Fleet integration configuration
}

run "test_with_custom_deployment_name" {
  command = plan

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.1.0/24"
    monitoring_subnet_cidr         = "10.0.2.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    license_key                    = "test-license-key"
    deployment_name                = "myproject-prod"
  }

  # Validates custom deployment name prefixing
}

run "test_with_enrichment" {
  command = plan

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.1.0/24"
    monitoring_subnet_cidr         = "10.0.2.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    license_key                    = "test-license-key"
    enrichment_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/enrichment"
  }

  # Validates enrichment integration configuration
}

run "test_with_security_options" {
  command = plan

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    virtual_network_name           = "test-vnet"
    virtual_network_resource_group = "networking-rg"
    management_subnet_cidr         = "10.0.1.0/24"
    monitoring_subnet_cidr         = "10.0.2.0/24"
    corelight_sensor_image_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    license_key                    = "test-license-key"
    fedramp_mode_enabled           = true
    prometheus_enabled             = true
    azure_fips_enabled             = true
  }

  # Validates security and compliance options
}

