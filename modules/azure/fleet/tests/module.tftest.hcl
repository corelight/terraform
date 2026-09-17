mock_provider "azurerm" {
  mock_data "azurerm_dns_zone" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns-rg/providers/Microsoft.Network/dnszones/example.com"
      name                = "example.com"
      resource_group_name = "dns-rg"
    }
  }
}

mock_provider "cloudinit" {}

run "verify_defaults" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.size == "Standard_D2s_v5"
    error_message = "Default VM size should be Standard_D2s_v5"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.admin_username == "corelight"
    error_message = "Default admin username should be corelight"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.os_disk[0].disk_size_gb == 50
    error_message = "Default OS disk size should be 50 GB"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.os_disk[0].storage_account_type == "StandardSSD_LRS"
    error_message = "OS disk should use StandardSSD_LRS"
  }

  assert {
    condition     = azurerm_lb.fleet.sku == "Standard"
    error_message = "Load balancer should use Standard SKU"
  }

  assert {
    condition     = azurerm_public_ip.fleet.sku == "Standard"
    error_message = "Public IP should use Standard SKU"
  }

  assert {
    condition     = azurerm_public_ip.fleet.allocation_method == "Static"
    error_message = "Public IP should use static allocation"
  }
}

run "verify_custom_vm_config" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "westus2"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    vm_size                        = "Standard_D4s_v5"
    os_disk_size_gb                = 100
    deployment_name                = "custom-fleet"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.size == "Standard_D4s_v5"
    error_message = "VM size should be customizable"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.os_disk[0].disk_size_gb == 100
    error_message = "OS disk size should be customizable"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.name == "custom-fleet-vm"
    error_message = "VM name should use custom deployment name prefix"
  }

  assert {
    condition     = azurerm_lb.fleet.name == "custom-fleet-lb"
    error_message = "LB name should use custom deployment name prefix"
  }

  assert {
    condition     = azurerm_network_security_group.fleet[0].name == "custom-fleet-nsg"
    error_message = "NSG name should use custom deployment name prefix"
  }
}

run "verify_lb_configuration" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = azurerm_lb_rule.https.frontend_port == 443
    error_message = "HTTPS LB rule should use frontend port 443"
  }

  assert {
    condition     = azurerm_lb_rule.https.backend_port == 443
    error_message = "HTTPS LB rule should use backend port 443"
  }

  assert {
    condition     = azurerm_lb_rule.https.protocol == "Tcp"
    error_message = "HTTPS LB rule should use TCP protocol"
  }

  assert {
    condition     = azurerm_lb_rule.api.frontend_port == 1443
    error_message = "API LB rule should use frontend port 1443"
  }

  assert {
    condition     = azurerm_lb_rule.api.backend_port == 1443
    error_message = "API LB rule should use backend port 1443"
  }

  assert {
    condition     = azurerm_lb_probe.https.port == 443
    error_message = "HTTPS probe should check port 443"
  }

  assert {
    condition     = azurerm_lb_probe.api.port == 1443
    error_message = "API probe should check port 1443"
  }
}

run "verify_nsg_created" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = length(azurerm_network_security_group.fleet) == 1
    error_message = "Should create NSG when no existing ID is provided"
  }

  assert {
    condition     = length(azurerm_network_security_rule.https_ingress) == 1
    error_message = "Should create HTTPS ingress rule"
  }

  assert {
    condition     = length(azurerm_network_security_rule.api_ingress) == 1
    error_message = "Should create API ingress rule"
  }

  assert {
    condition     = length(azurerm_network_security_rule.egress) == 1
    error_message = "Should create egress rule"
  }

  assert {
    condition     = length(azurerm_network_security_rule.ssh_ingress) == 0
    error_message = "Should not create SSH rule when admin_cidr_blocks is empty"
  }
}

run "verify_nsg_with_existing" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    nsg_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/existing-nsg"
  }

  assert {
    condition     = length(azurerm_network_security_group.fleet) == 0
    error_message = "Should not create NSG when existing ID is provided"
  }

  assert {
    condition     = length(azurerm_network_security_rule.https_ingress) == 0
    error_message = "Should not create rules when existing NSG is provided"
  }
}

run "verify_admin_ssh_access" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    admin_cidr_blocks              = ["203.0.113.0/24"]
  }

  assert {
    condition     = length(azurerm_network_security_rule.ssh_ingress) == 1
    error_message = "Should create SSH rule when admin_cidr_blocks is provided"
  }
}

run "verify_dns_enabled" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    dns_zone_name                  = "example.com"
    dns_zone_resource_group_name   = "dns-rg"
    subdomain                      = "fleet"
  }

  assert {
    condition     = length(azurerm_dns_a_record.fleet) == 1
    error_message = "Should create DNS record when dns_zone_name is set"
  }

  assert {
    condition     = azurerm_dns_a_record.fleet[0].name == "fleet"
    error_message = "DNS record name should match subdomain"
  }

  assert {
    condition     = azurerm_dns_a_record.fleet[0].ttl == 300
    error_message = "DNS record TTL should be 300"
  }
}

run "verify_dns_disabled" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = length(azurerm_dns_a_record.fleet) == 0
    error_message = "Should not create DNS record when dns_zone_name is not set"
  }
}

run "verify_custom_image" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    fleet_image_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/custom-fleet-image"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.source_image_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/images/custom-fleet-image"
    error_message = "Should use provided custom image ID"
  }
}

run "verify_tags_propagated" {
  command = plan

  module {
    source = "./."
  }

  variables {
    location                       = "eastus"
    resource_group_name            = "test-rg"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/fleet-subnet"
    ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDRbQ3S3IGxwpasfG+JOSGX3gfpTeMKJT0hZpBA3E3t2I9oo5f3D5tNMFfxOrBdNjFqQ3NzsswFpBKST5HToAWpzuoFCHQsgqxP1JruHp+bh3faCheNBsqMSvp5bDPTN5F2JTbsOateCRYjM3DDmvxqP+xEePhXoLnJWFLhfp8jmeXlKjqKqSfvLrhQgKJmr+NFI9q9bFv3dPnfXPIn+akE37dyhLMpWnqXiPuDjRoSVisWQq/RvPuTGlOtWJGnvpqpUl3kn3aBDwN0b0+F3u5HG0gyVwpJRV9mA0Gs9E4A5iN1l/LjW+5ZjHqO8g3bRqpLniwRBjFZjG0wjI7F0gWluKuQvGT9PI6AAV9XZPH3EQ4w3O8FgPpsqJ9s7+HqXXt4DNdT7xELhE9bPJjnuKlPLPBFkVTBPoZ2r0E3BVjF51wvG8AJRJ3rUF7VPuDRPq5k6cqRpqYvOIHvjGPlU2gQ5SgusTXn3xfvcP0diP5F9I5itsOSikM2tSj0= test@example.com"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    tags = {
      Environment = "test"
      Team        = "security"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.fleet.tags["Environment"] == "test"
    error_message = "Tags should be propagated to the VM"
  }

  assert {
    condition     = azurerm_lb.fleet.tags["Environment"] == "test"
    error_message = "Tags should be propagated to the LB"
  }

  assert {
    condition     = azurerm_public_ip.fleet.tags["Environment"] == "test"
    error_message = "Tags should be propagated to the public IP"
  }

  assert {
    condition     = azurerm_network_security_group.fleet[0].tags["Environment"] == "test"
    error_message = "Tags should be propagated to the NSG"
  }
}
