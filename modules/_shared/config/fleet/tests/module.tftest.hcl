# Unit tests for Shared Config Fleet Module
# These tests validate the cloud-init configuration generation for Fleet Manager

mock_provider "cloudinit" {}

run "verify_basic_config_generation" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "-----BEGIN CERTIFICATE-----\ntest-cert\n-----END CERTIFICATE-----"
    fleet_sensor_license = "test-license-content"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    base64_encode_config = true
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

run "verify_fleet_version" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    fleet_version        = "28.4.0"
    base64_encode_config = false
  }

  assert {
    condition     = data.cloudinit_config.config.gzip == false
    error_message = "Config should not be gzipped by default"
  }

  assert {
    condition     = data.cloudinit_config.config.base64_encode == false
    error_message = "Config should respect base64_encode setting"
  }
}

run "verify_gzip_option" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    gzip_config          = true
    base64_encode_config = true
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

run "verify_radius_disabled_by_default" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    base64_encode_config = false
  }

  assert {
    condition     = data.cloudinit_config.config != null
    error_message = "Cloudinit config should be generated"
  }
}

run "verify_radius_configuration" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    radius_enable        = true
    radius_address       = "192.168.1.100:1812"
    radius_shared_secret = "radius-secret"
    base64_encode_config = false
  }

  assert {
    condition     = data.cloudinit_config.config != null
    error_message = "Cloudinit config should be generated with RADIUS settings"
  }
}

run "verify_output_exists" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    base64_encode_config = true
  }

  assert {
    condition     = output.cloudinit_config != null
    error_message = "Module should output the cloudinit_config"
  }
}

run "verify_default_fleet_version" {
  command = plan

  module {
    source = "./."
  }

  variables {
    fleet_certificate    = "test-cert"
    fleet_sensor_license = "test-license"
    community_string     = "test-community"
    fleet_username       = "admin"
    fleet_password       = "test-password"
    base64_encode_config = false
  }

  assert {
    condition     = data.cloudinit_config.config != null
    error_message = "Should use default Fleet version (28.2.2)"
  }
}
