####################################################################################################
# Configure the provider
####################################################################################################

provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.region
  zone        = var.zone
}

####################################################################################################
# Create a VPC
####################################################################################################

# firewall

# allow ssh traffic to mgmt (default is inbound)
resource "google_compute_firewall" "allow_ssh_to_mgmt" {
  name      = var.firewall_ssh_to_mgmt_name
  direction = "INGRESS"
  network   = google_compute_network.mgmt.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# allow internal SSH traffic in mgmt network
resource "google_compute_firewall" "allow_internal" {
  name      = var.firewall_internal_name
  direction = "INGRESS"
  network   = google_compute_network.mgmt.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.subnetwork_mgmt_cidr]
  target_tags   = ["allow-ssh"]
}

# nat

resource "google_compute_router" "mgmt_router" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.mgmt.name
}

resource "google_compute_router_nat" "mon_nat" {
  name                               = var.nat_name
  router                             = google_compute_router.mgmt_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# network

resource "google_compute_network" "mgmt" {
  name                    = var.network_mgmt_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_network" "prod" {
  name                    = var.network_prod_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mgmt_subnet" {
  name          = var.subnetwork_mgmt_name
  ip_cidr_range = var.subnetwork_mgmt_cidr
  network       = google_compute_network.mgmt.name
  region        = var.region
}

resource "google_compute_subnetwork" "mon_subnet" {
  name          = var.subnetwork_mon_name
  ip_cidr_range = var.subnetwork_mon_cidr
  network       = google_compute_network.prod.name
  region        = var.region
}

####################################################################################################
# Create Sensor Managed Instance Group
####################################################################################################

module "sensor" {
  source = "../../../modules/gcp/sensor"

  project_id             = var.project_id
  region                 = var.region
  zones                  = var.zones
  network_mgmt_name      = google_compute_network.mgmt.name
  subnetwork_mgmt_name   = google_compute_subnetwork.mgmt_subnet.name
  network_prod_name      = google_compute_network.prod.name
  subnetwork_mon_name    = google_compute_subnetwork.mon_subnet.name
  subnetwork_mon_cidr    = var.subnetwork_mon_cidr
  subnetwork_mon_gateway = var.subnetwork_mon_gateway
  instance_ssh_key_pub   = var.instance_ssh_key_pub
  image                  = var.instance_sensor_image
  license_key            = var.license_key_file_path != "" ? file(var.license_key_file_path) : ""
  community_string       = var.community_string
  fleet_token            = var.fleet_token
  fleet_url              = var.fleet_url
  fleet_server_sslname   = var.fleet_server_sslname

  # Resource names
  instance_template_resource_name_prefix             = var.instance_template_resource_name_prefix
  instance_template_group_manager_resource_name      = var.instance_template_group_manager_resource_name
  instance_template_group_manager_base_instance_name = var.instance_template_group_manager_base_instance_name
  region_autoscaler_resource_name                    = var.region_autoscaler_resource_name
  region_health_check_resource_name                  = var.region_health_check_resource_name
  firewall_resource_name                             = var.firewall_resource_name
  region_backend_service_resource_name               = var.region_backend_service_resource_name
  forwarding_rule_resource_name                      = var.forwarding_rule_resource_name
  packet_mirroring_resource_name                     = var.packet_mirroring_resource_name
  packet_mirror_network_tag                          = var.packet_mirror_network_tag
}
