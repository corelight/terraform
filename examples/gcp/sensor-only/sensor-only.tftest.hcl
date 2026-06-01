# Unit tests for GCP Sensor-Only Example
# These tests validate the example configuration without deploying real infrastructure

mock_provider "google" {}
mock_provider "cloudinit" {}

run "verify_example_with_defaults" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    zone                   = "us-west1-a"
    subnetwork_mgmt_cidr   = "10.129.0.0/24"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    instance_sensor_image  = "test-sensor-image"
    license_key_file_path  = ""
    community_string       = "test-password"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
  }

  assert {
    condition     = google_compute_network.mgmt.name == "corelight-mgmt"
    error_message = "Management network should use default name"
  }

  assert {
    condition     = google_compute_network.prod.name == "corelight-prod"
    error_message = "Production network should use default name"
  }

  assert {
    condition     = google_compute_network.mgmt != null
    error_message = "Management network should be created"
  }

  assert {
    condition     = google_compute_network.prod != null
    error_message = "Production network should be created"
  }
}

run "verify_custom_network_names" {
  command = plan

  variables {
    project_id                = "test-project-123456"
    region                    = "us-west1"
    zone                      = "us-west1-a"
    network_mgmt_name         = "custom-mgmt"
    network_prod_name         = "custom-prod"
    subnetwork_mgmt_name      = "custom-mgmt-subnet"
    subnetwork_mon_name       = "custom-mon-subnet"
    subnetwork_mgmt_cidr      = "10.129.0.0/24"
    subnetwork_mon_cidr       = "10.3.0.0/24"
    subnetwork_mon_gateway    = "10.3.0.1"
    firewall_ssh_to_mgmt_name = "custom-ssh-rule"
    firewall_internal_name    = "custom-internal-rule"
    router_name               = "custom-router"
    nat_name                  = "custom-nat"
    instance_ssh_key_pub      = "/dev/null"
    instance_sensor_image     = "test-sensor-image"
    license_key_file_path     = ""
    community_string          = "test-password"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
  }

  assert {
    condition     = google_compute_network.mgmt.name == "custom-mgmt"
    error_message = "Management network name should be customizable"
  }

  assert {
    condition     = google_compute_network.prod.name == "custom-prod"
    error_message = "Production network name should be customizable"
  }

  assert {
    condition     = google_compute_subnetwork.mgmt_subnet.name == "custom-mgmt-subnet"
    error_message = "Management subnet name should be customizable"
  }

  assert {
    condition     = google_compute_subnetwork.mon_subnet.name == "custom-mon-subnet"
    error_message = "Monitoring subnet name should be customizable"
  }

  assert {
    condition     = google_compute_firewall.allow_ssh_to_mgmt.name == "custom-ssh-rule"
    error_message = "SSH firewall rule name should be customizable"
  }

  assert {
    condition     = google_compute_firewall.allow_internal.name == "custom-internal-rule"
    error_message = "Internal firewall rule name should be customizable"
  }

  assert {
    condition     = google_compute_router.mgmt_router.name == "custom-router"
    error_message = "Router name should be customizable"
  }

  assert {
    condition     = google_compute_router_nat.mon_nat.name == "custom-nat"
    error_message = "NAT name should be customizable"
  }
}

run "verify_sensor_resource_names" {
  command = plan

  variables {
    project_id                                    = "test-project-123456"
    region                                        = "us-west1"
    zone                                          = "us-west1-a"
    subnetwork_mgmt_cidr                          = "10.129.0.0/24"
    subnetwork_mon_cidr                           = "10.3.0.0/24"
    subnetwork_mon_gateway                        = "10.3.0.1"
    instance_ssh_key_pub                          = "/dev/null"
    instance_sensor_image                         = "test-sensor-image"
    license_key_file_path                         = ""
    community_string                              = "test-password"
    fleet_token                                   = "test-token"
    fleet_url                                     = "https://fleet.example.com"
    instance_template_resource_name_prefix        = "custom-template-"
    instance_template_group_manager_resource_name = "custom-mig"
    region_health_check_resource_name             = "custom-health"
    firewall_resource_name                        = "custom-sensor-fw"
  }

  assert {
    condition     = google_compute_router.mgmt_router.name != ""
    error_message = "Router should be created"
  }

  assert {
    condition     = google_compute_router_nat.mon_nat.name != ""
    error_message = "NAT should be created"
  }

  assert {
    condition     = google_compute_firewall.allow_ssh_to_mgmt.name != ""
    error_message = "SSH firewall rule should be created"
  }
}

run "verify_network_configuration" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    zone                   = "us-west1-a"
    subnetwork_mgmt_cidr   = "192.168.1.0/24"
    subnetwork_mon_cidr    = "192.168.2.0/24"
    subnetwork_mon_gateway = "192.168.2.1"
    instance_ssh_key_pub   = "/dev/null"
    instance_sensor_image  = "test-sensor-image"
    license_key_file_path  = ""
    community_string       = "test-password"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
  }

  assert {
    condition     = google_compute_subnetwork.mgmt_subnet.ip_cidr_range == "192.168.1.0/24"
    error_message = "Management subnet CIDR should be customizable"
  }

  assert {
    condition     = google_compute_subnetwork.mon_subnet.ip_cidr_range == "192.168.2.0/24"
    error_message = "Monitoring subnet CIDR should be customizable"
  }

  assert {
    condition     = google_compute_subnetwork.mgmt_subnet.network == google_compute_network.mgmt.name
    error_message = "Management subnet should be in management network"
  }

  assert {
    condition     = google_compute_subnetwork.mon_subnet.network == google_compute_network.prod.name
    error_message = "Monitoring subnet should be in production network"
  }
}
