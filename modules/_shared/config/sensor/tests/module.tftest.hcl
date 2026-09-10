# Unit tests for Shared Config Sensor Module
# These tests validate the cloud-init configuration generation

mock_provider "cloudinit" {}

run "verify_basic_config_generation" {
  command = plan

  module {
    source = "./."
  }

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    base64_encode_config             = true
    sensor_health_check_http_port    = "41080"
  }

  assert {
    condition     = data.cloudinit_config.config.gzip == false
    error_message = "Config should not be gzipped by default"
  }

  assert {
    condition     = data.cloudinit_config.config.base64_encode == true
    error_message = "Config should be base64 encoded when specified"
  }
}

run "verify_fleet_config" {
  command = plan

  module {
    source = "./."
  }

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    fleet_token                      = "test-token"
    fleet_url                        = "https://fleet.example.com"
    fleet_server_sslname             = "fleet.example.com"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    base64_encode_config             = true
    sensor_health_check_http_port    = "41080"
  }

  assert {
    condition     = data.cloudinit_config.config.base64_encode == true
    error_message = "Config should be base64 encoded"
  }

  assert {
    condition     = data.cloudinit_config.config.gzip == false
    error_message = "Config should not be gzipped by default"
  }
}

run "verify_gzip_option" {
  command = plan

  module {
    source = "./."
  }

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    base64_encode_config             = true
    gzip_config                      = true
    sensor_health_check_http_port    = "41080"
  }

  assert {
    condition     = data.cloudinit_config.config.gzip == true
    error_message = "Config should be gzipped when specified"
  }

  assert {
    condition     = data.cloudinit_config.config.base64_encode == true
    error_message = "Config should be base64 encoded when gzip is enabled"
  }
}

run "verify_output_exists" {
  command = plan

  module {
    source = "./."
  }

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    base64_encode_config             = true
    sensor_health_check_http_port    = "41080"
  }

  assert {
    condition     = output.cloudinit_config != null
    error_message = "Module should output the cloudinit_config"
  }
}

run "verify_deployment_metadata" {
  command = plan

  variables {
    sensor_license                       = "test-license-key"
    fleet_community_string               = "test-community"
    sensor_management_interface_name     = "eth1"
    sensor_monitoring_interface_name     = "eth0"
    deployment_cloud_provider            = "aws"
    deployment_cloud_region              = "us-east-1"
    deployment_traffic_mirroring_enabled = true
  }

  assert {
    condition = strcontains(
      data.cloudinit_config.config.part[0].content,
      "path: /etc/corelight/deployment-metadata.yaml",
    )
    error_message = "Cloud-init should persist deployment metadata"
  }

  assert {
    condition     = strcontains(local.deployment_metadata_yaml, "deployment_metadata.cloud_provider")
    error_message = "Metadata should contain provider"
  }

  assert {
    condition     = strcontains(local.deployment_metadata_yaml, "deployment_metadata.cloud_region")
    error_message = "Metadata should contain region"
  }

  assert {
    condition     = strcontains(local.deployment_metadata_yaml, "deployment_metadata.cloud_traffic_mirroring_enabled")
    error_message = "Known mirroring state should be rendered"
  }

  assert {
    condition = strcontains(
      data.cloudinit_config.config.part[0].content,
      "corelightctl sensor configuration put --file /etc/corelight/deployment-metadata.yaml",
    )
    error_message = "Cloud-init should apply metadata through the existing configuration command"
  }
}

run "verify_unknown_mirroring_is_omitted" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    deployment_cloud_provider        = "azure"
    deployment_cloud_region          = "eastus"
  }

  assert {
    condition     = !strcontains(local.deployment_metadata_yaml, "traffic_mirroring")
    error_message = "Unknown mirroring state should be omitted"
  }
}

run "reject_invalid_deployment_provider" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    deployment_cloud_provider        = "openstack"
    deployment_cloud_region          = "region-one"
  }

  expect_failures = [var.deployment_cloud_provider]
}

run "verify_false_mirroring" {
  command = plan

  variables {
    sensor_license                       = "test-license-key"
    fleet_community_string               = "test-community"
    sensor_management_interface_name     = "eth1"
    sensor_monitoring_interface_name     = "eth0"
    deployment_cloud_provider            = "azure"
    deployment_cloud_region              = "eastus"
    deployment_traffic_mirroring_enabled = false
  }

  assert {
    condition = strcontains(
      local.deployment_metadata_yaml,
      "deployment_metadata.cloud_traffic_mirroring_enabled",
    ) && strcontains(local.deployment_metadata_yaml, "false")
    error_message = "Explicit false mirroring state should be retained"
  }
}

run "verify_absent_deployment_metadata" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
  }

  assert {
    condition = !strcontains(
      data.cloudinit_config.config.part[0].content,
      "/etc/corelight/deployment-metadata.yaml",
    )
    error_message = "Direct callers without metadata should retain the old cloud-init"
  }
}

run "reject_multibyte_deployment_region_over_255_bytes" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    deployment_cloud_provider        = "gcp"
    deployment_cloud_region          = join("", [for i in range(128) : "é"])
  }

  expect_failures = [var.deployment_cloud_region]
}

run "reject_unicode_control_deployment_region" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    deployment_cloud_provider        = "aws"
    deployment_cloud_region          = "us\u0085east"
  }

  expect_failures = [var.deployment_cloud_region]
}

run "verify_metadata_application_follows_successful_deploy" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    deployment_cloud_provider        = "aws"
    deployment_cloud_region          = "us-east-1"
  }

  assert {
    condition = strcontains(
      data.cloudinit_config.config.part[0].content,
      "    if ! corelightctl sensor deploy -v; then\n      exit 1\n    fi\n    if ! corelightctl sensor configuration put --file /etc/corelight/deployment-metadata.yaml; then\n      logger -t corelight-deployment-metadata \"Sensor API did not accept deployment metadata; inventory fields will remain null\"\n    fi",
    )
    error_message = "Metadata application should follow a successful deploy and remain best-effort"
  }
}
