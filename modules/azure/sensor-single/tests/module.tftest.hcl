# Unit tests for Azure Single Sensor Module

mock_provider "azurerm" {}
mock_provider "cloudinit" {}

run "verify_terraform_module_identity" {
  command = plan

  variables {
    location                  = "eastus"
    resource_group_name       = "test-rg"
    license_key               = "test-license-key"
    corelight_sensor_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/corelight-sensor"
    sensor_ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string          = "test-community"
    management_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mgmt-subnet"
    monitoring_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/mon-subnet"
  }

  assert {
    condition = try(
      yamldecode(base64decode(trimspace(split("\n", split("content: ", split("path: /etc/corelight/deployment-metadata.yaml", module.sensor_config[0].cloudinit_config.part[0].content)[1])[1])[0])))["deployment_metadata.terraform_module"] == "azure/sensor-single",
      false,
    )
    error_message = "Provider module should pass its Terraform module identity"
  }
}
