####################################################################################################
# GCP NSI Out-of-Band Mirroring Example
#
# This example demonstrates how to set up Network Security Integration (NSI) out-of-band mirroring
# with Corelight sensors in GCP. NSI mirroring uses Geneve encapsulation (UDP 6081) to deliver
# mirrored traffic from producer VPCs to sensor instances via an Internal Load Balancer.
#
# Architecture:
# - Producer VPCs (workloads) send mirrored traffic via NSI Endpoint Group Associations
# - Traffic flows to Regional ILB with is_mirroring_collector = true
# - ILB distributes to Regional MIG of Corelight sensors
# - Sensors have dual NICs: eth0 (mgmt), eth1 (monitoring)
#
# Requirements:
# - google provider >= 6.38.0
# - google-beta provider >= 7.15.0
# - Organization-level Security Profile Group (created by IT team)
####################################################################################################

####################################################################################################
# Configure the providers
####################################################################################################

provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.region
  zone        = var.zone
}

####################################################################################################
# Fetch available zones in the region
####################################################################################################

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

####################################################################################################
# Consumer Project: VPC Networks for Corelight Sensors
####################################################################################################

# Management VPC (eth0 - SSH, Fleet management)
resource "google_compute_network" "mgmt_network" {
  name                    = var.network_mgmt_name != "" ? var.network_mgmt_name : "${var.sensor_network_name}-mgmt"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Management VPC network for Corelight sensors"
}

# Monitoring VPC (eth1 - receives mirrored traffic)
resource "google_compute_network" "sensor_network" {
  name                    = var.sensor_network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Monitoring VPC network for Corelight sensors to receive mirrored traffic"
}

# Management subnet
resource "google_compute_subnetwork" "mgmt_subnet" {
  name          = var.subnetwork_mgmt_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.mgmt_network.id
  ip_cidr_range = var.subnetwork_mgmt_cidr
  description   = "Management subnet for Corelight sensors"
}

# Monitoring subnet
resource "google_compute_subnetwork" "mon_subnet" {
  name          = var.subnetwork_mon_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.sensor_network.id
  ip_cidr_range = var.subnetwork_mon_cidr
  description   = "Monitoring subnet for Corelight sensors to receive mirrored traffic"
}

####################################################################################################
# Consumer Project: Firewall Rules
####################################################################################################

# Allow SSH from IAP (Identity-Aware Proxy)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_mgmt_name != "" ? var.network_mgmt_name : "${var.sensor_network_name}-mgmt"}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.mgmt_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh"]
  description   = "Allow SSH access from Identity-Aware Proxy"
}

# Allow Geneve-encapsulated mirrored traffic (UDP 6081)
resource "google_compute_firewall" "allow_geneve" {
  name    = "${var.sensor_network_name}-allow-geneve"
  project = var.project_id
  network = google_compute_network.sensor_network.name

  allow {
    protocol = "udp"
    ports    = ["6081"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["sensor"]
  description   = "Allow Geneve-encapsulated mirrored traffic (UDP 6081) for NSI out-of-band mirroring"
}

# Allow health check probes
resource "google_compute_firewall" "sensor_health_check_rule" {
  name          = var.firewall_resource_name
  project       = var.project_id
  direction     = "INGRESS"
  network       = google_compute_network.sensor_network.id
  source_ranges = var.region_probe_source_ranges_cidr

  allow {
    protocol = "tcp"
    ports    = [var.health_check_http_port]
  }

  target_tags = ["sensor"]
  description = "Allow health check probes from GCP health check ranges"
}

####################################################################################################
# Consumer Project: Sensor Configuration (Fleet, licenses, etc.)
####################################################################################################

module "sensor_config" {
  source = "../../../modules/_shared/config/sensor"

  fleet_community_string = var.community_string
  fleet_token            = var.fleet_token
  fleet_url              = var.fleet_url
  fleet_server_sslname   = var.fleet_server_sslname
  fleet_http_proxy       = var.fleet_http_proxy
  fleet_https_proxy      = var.fleet_https_proxy
  fleet_no_proxy         = var.fleet_no_proxy

  sensor_license                               = var.license_key_file_path != "" ? file(var.license_key_file_path) : ""
  sensor_management_interface_name             = "eth0"
  sensor_monitoring_interface_name             = "eth1"
  sensor_health_check_probe_source_ranges_cidr = var.region_probe_source_ranges_cidr
  subnetwork_monitoring_cidr                   = var.subnetwork_mon_cidr
  subnetwork_monitoring_gateway                = var.subnetwork_mon_gateway
}

####################################################################################################
# Consumer Project: Sensor Instance Template and MIG
####################################################################################################

resource "google_compute_instance_template" "sensor_template" {
  project      = var.project_id
  region       = var.region
  name_prefix  = var.instance_template_resource_name_prefix
  machine_type = var.instance_size
  tags         = ["allow-ssh", "corelight", "sensor", "allow-health-check"]

  dynamic "service_account" {
    for_each = var.sensor_service_account_email == "" ? toset([]) : toset([1])

    content {
      scopes = ["cloud-platform"]
      email  = var.sensor_service_account_email
    }
  }

  disk {
    source_image = var.image
    disk_size_gb = var.image_disk_size
    auto_delete  = true
    boot         = true
    disk_type    = "pd-ssd"
  }

  metadata = {
    ssh-keys  = "${var.instance_ssh_user}:${file(var.instance_ssh_key_pub)}"
    user-data = module.sensor_config.cloudinit_config.rendered
  }

  # eth0 - Management interface
  network_interface {
    network            = google_compute_network.mgmt_network.id
    subnetwork         = google_compute_subnetwork.mgmt_subnet.id
    subnetwork_project = var.project_id
  }

  # eth1 - Monitoring interface (receives mirrored traffic)
  network_interface {
    network            = google_compute_network.sensor_network.id
    subnetwork         = google_compute_subnetwork.mon_subnet.id
    subnetwork_project = var.project_id
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "sensor_mig" {
  name               = var.instance_template_group_manager_resource_name
  project            = var.project_id
  region             = var.region
  base_instance_name = var.instance_template_group_manager_base_instance_name

  distribution_policy_zones = local.distribution_zones

  version {
    instance_template = google_compute_instance_template.sensor_template.id
    name              = "Corelight-Sensor"
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.traffic_mon_health_check.id
    initial_delay_sec = 600
  }
}

# Regional Autoscaler
resource "google_compute_region_autoscaler" "sensor_autoscaler" {
  name    = var.region_autoscaler_resource_name
  project = var.project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.sensor_mig.id

  autoscaling_policy {
    max_replicas    = var.region_autoscaler_policy_max_replicas
    min_replicas    = var.region_autoscaler_policy_min_replicas
    cooldown_period = var.region_autoscaler_policy_cooldown_period

    cpu_utilization {
      target = var.region_autoscaler_policy_cpu_utilization_target
    }
  }
}

####################################################################################################
# Consumer Project: Internal Load Balancer (NSI Mirroring Collector)
####################################################################################################

# Health check
resource "google_compute_region_health_check" "traffic_mon_health_check" {
  name               = var.region_health_check_resource_name
  project            = var.project_id
  region             = var.region
  check_interval_sec = 30
  timeout_sec        = 30

  http_health_check {
    port         = var.health_check_http_port
    request_path = "/api/system/healthcheck"
    response     = "{\"message\":\"OK\"}"
  }
}

# Backend service
resource "google_compute_region_backend_service" "traffic_ilb_backend_service" {
  name                  = var.region_backend_service_resource_name
  project               = var.project_id
  region                = var.region
  health_checks         = [google_compute_region_health_check.traffic_mon_health_check.id]
  protocol              = "UDP"
  network               = google_compute_network.sensor_network.id
  load_balancing_scheme = "INTERNAL"
  session_affinity      = "NONE"

  backend {
    group          = google_compute_region_instance_group_manager.sensor_mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

# Internal Load Balancer forwarding rule (mirroring collector)
resource "google_compute_forwarding_rule" "traffic_forwarding_rule" {
  name                   = var.forwarding_rule_resource_name
  project                = var.project_id
  backend_service        = google_compute_region_backend_service.traffic_ilb_backend_service.id
  region                 = var.region
  network                = google_compute_network.sensor_network.id
  subnetwork             = google_compute_subnetwork.mon_subnet.id
  is_mirroring_collector = true
  ip_protocol            = "UDP"
  load_balancing_scheme  = "INTERNAL"
  all_ports              = true
}

####################################################################################################
# NSI Mirroring Resources
####################################################################################################

locals {
  sensor_network_url = google_compute_network.sensor_network.self_link
  vpcs_to_mirror     = var.mirrored_vpcs
  distribution_zones = length(var.zones) > 0 ? var.zones : data.google_compute_zones.available.names

  # Create a map of VPCs for for_each usage
  vpcs_map = {
    for vpc in local.vpcs_to_mirror :
    basename(vpc.network) => {
      network        = startswith(vpc.network, "projects/") ? vpc.network : "projects/${coalesce(vpc.project_id, var.project_id)}/global/networks/${vpc.network}"
      network_name   = basename(vpc.network)
      project_id     = coalesce(vpc.project_id, var.project_id)
      association_id = "${basename(vpc.network)}-association"
    }
  }

  # Full resource ID for org-level security profile group
  security_profile_group_id = var.security_profile_group_id != "" ? var.security_profile_group_id : (
    var.organization_id != "" ?
    "organizations/${var.organization_id}/locations/global/securityProfileGroups/${var.mirroring_profile_group_name}" :
    ""
  )
}

# Mirroring Deployment Group (global) - contains both Deployment and Endpoint Group
resource "google_network_security_mirroring_deployment_group" "mirroring_group" {
  mirroring_deployment_group_id = var.mirroring_deployment_group_id
  project                       = var.project_id
  location                      = "global"
  network                       = local.sensor_network_url
  labels                        = var.mirroring_labels
}

# Mirroring Deployment (zonal) - references ILB forwarding rule
# Note: Only ONE deployment per forwarding rule. Regional ILB distributes to all zones.
resource "google_network_security_mirroring_deployment" "mirroring_deployment" {
  mirroring_deployment_id    = var.mirroring_deployment_id
  project                    = var.project_id
  location                   = var.zone
  mirroring_deployment_group = google_network_security_mirroring_deployment_group.mirroring_group.id
  forwarding_rule            = google_compute_forwarding_rule.traffic_forwarding_rule.id
  labels                     = var.mirroring_labels
}

# Mirroring Endpoint Group (global) - referenced by Security Profile in producer projects
resource "google_network_security_mirroring_endpoint_group" "mirroring_endpoint" {
  mirroring_endpoint_group_id = var.mirroring_endpoint_group_id
  project                     = var.project_id
  location                    = "global"
  mirroring_deployment_group  = google_network_security_mirroring_deployment_group.mirroring_group.id
  labels                      = var.mirroring_labels
}

# Endpoint Group Associations (one per producer VPC) - links producer VPCs to Endpoint Group
resource "google_network_security_mirroring_endpoint_group_association" "vpc_associations" {
  for_each = local.vpcs_map

  mirroring_endpoint_group_association_id = each.value.association_id
  project                                 = each.value.project_id
  location                                = "global"
  mirroring_endpoint_group                = google_network_security_mirroring_endpoint_group.mirroring_endpoint.id
  network                                 = each.value.network
  labels                                  = var.mirroring_labels
}

####################################################################################################
# Producer Project: Network Firewall Policies with Mirroring Rules
####################################################################################################

# Create global network firewall policy for each mirrored VPC
resource "google_compute_network_firewall_policy" "mirror_policies" {
  for_each = local.vpcs_map

  name        = "${each.value.network_name}-mirror-policy"
  project     = each.value.project_id
  description = "Global network firewall policy with mirroring rules for ${each.value.network_name}"
}

# Ingress mirroring rule
resource "google_compute_network_firewall_policy_packet_mirroring_rule" "mirror_ingress" {
  provider = google-beta
  for_each = local.vpcs_map

  action                 = "mirror"
  description            = "Mirror ingress traffic to Corelight sensor"
  direction              = "INGRESS"
  firewall_policy        = google_compute_network_firewall_policy.mirror_policies[each.key].name
  priority               = 10
  rule_name              = "mirror-ingress-all"
  project                = each.value.project_id
  security_profile_group = local.security_profile_group_id

  match {
    src_ip_ranges = var.mirroring_src_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# Egress mirroring rule
resource "google_compute_network_firewall_policy_packet_mirroring_rule" "mirror_egress" {
  provider = google-beta
  for_each = local.vpcs_map

  action                 = "mirror"
  description            = "Mirror egress traffic to Corelight sensor"
  direction              = "EGRESS"
  firewall_policy        = google_compute_network_firewall_policy.mirror_policies[each.key].name
  priority               = 11
  rule_name              = "mirror-egress-all"
  project                = each.value.project_id
  security_profile_group = local.security_profile_group_id

  match {
    dest_ip_ranges = var.mirroring_dest_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# Associate firewall policy with each producer VPC
resource "google_compute_network_firewall_policy_association" "mirror_associations" {
  for_each = local.vpcs_map

  name              = "${each.value.network_name}-mirror-association"
  attachment_target = each.value.network
  firewall_policy   = google_compute_network_firewall_policy.mirror_policies[each.key].name
  project           = each.value.project_id
}
