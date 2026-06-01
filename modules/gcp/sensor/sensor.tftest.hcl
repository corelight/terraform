# Unit tests for GCP Sensor Module
# These tests validate the module configuration without deploying real infrastructure

mock_provider "google" {}
mock_provider "cloudinit" {}

run "verify_required_variables" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    network_mgmt_name      = "test-mgmt-network"
    subnetwork_mgmt_name   = "test-mgmt-subnet"
    network_prod_name      = "test-prod-network"
    subnetwork_mon_name    = "test-mon-subnet"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    image                  = "test-sensor-image"
    license_key            = "test-license-key"
    community_string       = "test-community-string"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
    fleet_server_sslname   = "fleet.example.com"
  }

  assert {
    condition     = google_compute_instance_template.sensor_template.name_prefix == "corelight-mig-template-"
    error_message = "Instance template name prefix should default to 'corelight-mig-template-'"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.sensor_mig.name == "corelight-mig-manager"
    error_message = "MIG manager name should default to 'corelight-mig-manager'"
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.name == "corelight-autoscale"
    error_message = "Autoscaler name should default to 'corelight-autoscale'"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.name == "corelight-traffic-monitor-health-check"
    error_message = "Health check name should default to 'corelight-traffic-monitor-health-check'"
  }
}

run "verify_custom_names" {
  command = plan

  variables {
    project_id                                         = "test-project-123456"
    region                                             = "us-west1"
    network_mgmt_name                                  = "test-mgmt-network"
    subnetwork_mgmt_name                               = "test-mgmt-subnet"
    network_prod_name                                  = "test-prod-network"
    subnetwork_mon_name                                = "test-mon-subnet"
    subnetwork_mon_cidr                                = "10.3.0.0/24"
    subnetwork_mon_gateway                             = "10.3.0.1"
    instance_ssh_key_pub                               = "/dev/null"
    image                                              = "test-sensor-image"
    license_key                                        = "test-license-key"
    community_string                                   = "test-community-string"
    fleet_token                                        = "test-token"
    fleet_url                                          = "https://fleet.example.com"
    fleet_server_sslname                               = "fleet.example.com"
    instance_template_resource_name_prefix             = "custom-template-"
    instance_template_group_manager_resource_name      = "custom-mig"
    instance_template_group_manager_base_instance_name = "custom-sensor"
    region_autoscaler_resource_name                    = "custom-autoscale"
    region_health_check_resource_name                  = "custom-health-check"
    firewall_resource_name                             = "custom-firewall"
    region_backend_service_resource_name               = "custom-backend"
    forwarding_rule_resource_name                      = "custom-forwarding"
    packet_mirroring_resource_name                     = "custom-mirroring"
  }

  assert {
    condition     = google_compute_instance_template.sensor_template.name_prefix == "custom-template-"
    error_message = "Instance template name prefix should be customizable"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.sensor_mig.name == "custom-mig"
    error_message = "MIG manager name should be customizable"
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.name == "custom-autoscale"
    error_message = "Autoscaler name should be customizable"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.name == "custom-health-check"
    error_message = "Health check name should be customizable"
  }

  assert {
    condition     = google_compute_firewall.sensor_health_check_rule.name == "custom-firewall"
    error_message = "Firewall rule name should be customizable"
  }

  assert {
    condition     = google_compute_region_backend_service.traffic_ilb_backend_service.name == "custom-backend"
    error_message = "Backend service name should be customizable"
  }

  assert {
    condition     = google_compute_forwarding_rule.traffic_forwarding_rule.name == "custom-forwarding"
    error_message = "Forwarding rule name should be customizable"
  }

  assert {
    condition     = google_compute_packet_mirroring.traffic_mirror.name == "custom-mirroring"
    error_message = "Packet mirroring name should be customizable"
  }
}

run "verify_mig_configuration" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    network_mgmt_name      = "test-mgmt-network"
    subnetwork_mgmt_name   = "test-mgmt-subnet"
    network_prod_name      = "test-prod-network"
    subnetwork_mon_name    = "test-mon-subnet"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    image                  = "test-sensor-image"
    license_key            = "test-license-key"
    community_string       = "test-community-string"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
    fleet_server_sslname   = "fleet.example.com"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.sensor_mig.base_instance_name == "corelight"
    error_message = "Base instance name should default to 'corelight'"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.sensor_mig.region == "us-west1"
    error_message = "MIG should be created in specified region"
  }

  assert {
    condition     = google_compute_region_instance_group_manager.sensor_mig.version[0].name == "Corelight-Sensor"
    error_message = "MIG version name should be 'Corelight-Sensor'"
  }
}

run "verify_autoscaler_configuration" {
  command = plan

  variables {
    project_id                                      = "test-project-123456"
    region                                          = "us-west1"
    network_mgmt_name                               = "test-mgmt-network"
    subnetwork_mgmt_name                            = "test-mgmt-subnet"
    network_prod_name                               = "test-prod-network"
    subnetwork_mon_name                             = "test-mon-subnet"
    subnetwork_mon_cidr                             = "10.3.0.0/24"
    subnetwork_mon_gateway                          = "10.3.0.1"
    instance_ssh_key_pub                            = "/dev/null"
    image                                           = "test-sensor-image"
    license_key                                     = "test-license-key"
    community_string                                = "test-community-string"
    fleet_token                                     = "test-token"
    fleet_url                                       = "https://fleet.example.com"
    fleet_server_sslname                            = "fleet.example.com"
    region_autoscaler_policy_min_replicas           = 2
    region_autoscaler_policy_max_replicas           = 10
    region_autoscaler_policy_cooldown_period        = 300
    region_autoscaler_policy_cpu_utilization_target = 0.6
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.autoscaling_policy[0].min_replicas == 2
    error_message = "Autoscaler min replicas should be customizable"
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.autoscaling_policy[0].max_replicas == 10
    error_message = "Autoscaler max replicas should be customizable"
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.autoscaling_policy[0].cooldown_period == 300
    error_message = "Autoscaler cooldown period should be customizable"
  }

  assert {
    condition     = google_compute_region_autoscaler.sensor_autoscaler.autoscaling_policy[0].cpu_utilization[0].target == 0.6
    error_message = "Autoscaler CPU target should be customizable"
  }
}

run "verify_health_check_configuration" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    network_mgmt_name      = "test-mgmt-network"
    subnetwork_mgmt_name   = "test-mgmt-subnet"
    network_prod_name      = "test-prod-network"
    subnetwork_mon_name    = "test-mon-subnet"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    image                  = "test-sensor-image"
    license_key            = "test-license-key"
    community_string       = "test-community-string"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
    fleet_server_sslname   = "fleet.example.com"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.http_health_check[0].port == 41080
    error_message = "Health check should use port 41080"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.http_health_check[0].request_path == "/api/system/healthcheck"
    error_message = "Health check should use correct endpoint path"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.http_health_check[0].response == "{\"message\":\"OK\"}"
    error_message = "Health check should expect correct response"
  }

  assert {
    condition     = google_compute_region_health_check.traffic_mon_health_check.check_interval_sec == 30
    error_message = "Health check interval should be 30 seconds"
  }
}

run "verify_instance_template_configuration" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    network_mgmt_name      = "test-mgmt-network"
    subnetwork_mgmt_name   = "test-mgmt-subnet"
    network_prod_name      = "test-prod-network"
    subnetwork_mon_name    = "test-mon-subnet"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    image                  = "test-sensor-image"
    license_key            = "test-license-key"
    community_string       = "test-community-string"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
    fleet_server_sslname   = "fleet.example.com"
    instance_size          = "e2-standard-16"
  }

  assert {
    condition     = google_compute_instance_template.sensor_template.machine_type == "e2-standard-16"
    error_message = "Instance type should be customizable"
  }

  assert {
    condition     = google_compute_instance_template.sensor_template.disk[0].disk_type == "pd-ssd"
    error_message = "Disk type should be pd-ssd"
  }

  assert {
    condition     = length(google_compute_instance_template.sensor_template.network_interface) == 2
    error_message = "Instance template should have 2 network interfaces (mgmt + monitoring)"
  }
}

run "verify_load_balancer_configuration" {
  command = plan

  variables {
    project_id             = "test-project-123456"
    region                 = "us-west1"
    network_mgmt_name      = "test-mgmt-network"
    subnetwork_mgmt_name   = "test-mgmt-subnet"
    network_prod_name      = "test-prod-network"
    subnetwork_mon_name    = "test-mon-subnet"
    subnetwork_mon_cidr    = "10.3.0.0/24"
    subnetwork_mon_gateway = "10.3.0.1"
    instance_ssh_key_pub   = "/dev/null"
    image                  = "test-sensor-image"
    license_key            = "test-license-key"
    community_string       = "test-community-string"
    fleet_token            = "test-token"
    fleet_url              = "https://fleet.example.com"
    fleet_server_sslname   = "fleet.example.com"
  }

  assert {
    condition     = google_compute_region_backend_service.traffic_ilb_backend_service.load_balancing_scheme == "INTERNAL"
    error_message = "Backend service should use INTERNAL load balancing"
  }

  assert {
    condition     = google_compute_region_backend_service.traffic_ilb_backend_service.protocol == "TCP"
    error_message = "Backend service should use TCP protocol"
  }

  assert {
    condition     = google_compute_forwarding_rule.traffic_forwarding_rule.is_mirroring_collector == true
    error_message = "Forwarding rule should be configured as mirroring collector"
  }

  assert {
    condition     = google_compute_forwarding_rule.traffic_forwarding_rule.all_ports == true
    error_message = "Forwarding rule should forward all ports"
  }
}

run "verify_packet_mirroring_configuration" {
  command = plan

  variables {
    project_id                = "test-project-123456"
    region                    = "us-west1"
    network_mgmt_name         = "test-mgmt-network"
    subnetwork_mgmt_name      = "test-mgmt-subnet"
    network_prod_name         = "test-prod-network"
    subnetwork_mon_name       = "test-mon-subnet"
    subnetwork_mon_cidr       = "10.3.0.0/24"
    subnetwork_mon_gateway    = "10.3.0.1"
    instance_ssh_key_pub      = "/dev/null"
    image                     = "test-sensor-image"
    license_key               = "test-license-key"
    community_string          = "test-community-string"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
    packet_mirror_network_tag = "custom-traffic-source"
  }

  assert {
    condition     = google_compute_packet_mirroring.traffic_mirror.mirrored_resources[0].tags[0] == "custom-traffic-source"
    error_message = "Packet mirroring should use custom network tag"
  }

  assert {
    condition     = google_compute_packet_mirroring.traffic_mirror.filter[0].direction == "BOTH"
    error_message = "Packet mirroring should capture bidirectional traffic"
  }
}

run "verify_firewall_configuration" {
  command = plan

  variables {
    project_id                      = "test-project-123456"
    region                          = "us-west1"
    network_mgmt_name               = "test-mgmt-network"
    subnetwork_mgmt_name            = "test-mgmt-subnet"
    network_prod_name               = "test-prod-network"
    subnetwork_mon_name             = "test-mon-subnet"
    subnetwork_mon_cidr             = "10.3.0.0/24"
    subnetwork_mon_gateway          = "10.3.0.1"
    instance_ssh_key_pub            = "/dev/null"
    image                           = "test-sensor-image"
    license_key                     = "test-license-key"
    community_string                = "test-community-string"
    fleet_token                     = "test-token"
    fleet_url                       = "https://fleet.example.com"
    fleet_server_sslname            = "fleet.example.com"
    region_probe_source_ranges_cidr = ["130.211.0.0/22", "35.191.0.0/16"]
  }

  assert {
    condition     = google_compute_firewall.sensor_health_check_rule.direction == "INGRESS"
    error_message = "Firewall rule should be for ingress traffic"
  }

  assert {
    condition     = contains(google_compute_firewall.sensor_health_check_rule.target_tags, "sensor")
    error_message = "Firewall rule should target 'sensor' tag"
  }

  assert {
    condition     = contains(google_compute_firewall.sensor_health_check_rule.source_ranges, "130.211.0.0/22")
    error_message = "Firewall rule should allow GCP health check ranges"
  }
}
