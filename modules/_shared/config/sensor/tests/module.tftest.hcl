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
