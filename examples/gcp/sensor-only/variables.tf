# GCP Configuration

variable "project_id" {
  description = "GCP project ID where resources will be deployed"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
}

variable "zone" {
  description = "GCP zone within the region (used for provider default)"
  type        = string
}

variable "zones" {
  description = "List of zones to distribute sensors across. If empty, sensors are distributed across all available zones in the region."
  type        = list(string)
  default     = []
}

# Authentication

variable "credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = "~/.config/gcloud/application_default_credentials.json"
}

# Network Configuration

variable "network_mgmt_name" {
  description = "Name of the management VPC network"
  type        = string
  default     = "corelight-mgmt"
}

variable "network_prod_name" {
  description = "Name of the production VPC network"
  type        = string
  default     = "corelight-prod"
}

variable "subnetwork_mgmt_name" {
  description = "Name of the management subnet"
  type        = string
  default     = "corelight-subnet"
}

variable "subnetwork_mon_name" {
  description = "Name of the monitoring subnet"
  type        = string
  default     = "corelight-mon-subnet"
}

variable "subnetwork_mgmt_cidr" {
  description = "CIDR block for management subnet"
  type        = string
}

variable "subnetwork_mon_cidr" {
  description = "CIDR block for monitoring subnet"
  type        = string
}

variable "subnetwork_mon_gateway" {
  description = "Gateway IP for monitoring subnet"
  type        = string
}

# Firewall Configuration

variable "firewall_ssh_to_mgmt_name" {
  description = "Name of the firewall rule allowing SSH to management network"
  type        = string
  default     = "corelight-allow-ssh-inbound-to-mgmt"
}

variable "firewall_internal_name" {
  description = "Name of the firewall rule allowing internal SSH traffic"
  type        = string
  default     = "corelight-allow-internal"
}

# Router and NAT Configuration

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
  default     = "corelight-mgmt-router"
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
  default     = "corelight-mgmt-nat"
}

# SSH Configuration

variable "instance_ssh_key_pub" {
  description = "Path to SSH public key for instance access"
  type        = string
}

# Image Configuration

variable "instance_sensor_image" {
  description = "Corelight sensor image name"
  type        = string
}

# Corelight Configuration

variable "license_key_file_path" {
  description = "Path to Corelight sensor license file (optional if using Fleet)"
  type        = string
  default     = ""
}

variable "community_string" {
  description = "Community string (API password) for sensor management"
  type        = string
  sensitive   = true
}

# Fleet Configuration

variable "fleet_token" {
  description = "Fleet pairing token from Fleet UI"
  type        = string
  sensitive   = true
}

variable "fleet_url" {
  description = "Fleet instance URL"
  type        = string
}

variable "fleet_server_sslname" {
  description = "SSL hostname for Fleet server"
  type        = string
  default     = ""
}

# Sensor Resource Names

variable "instance_template_resource_name_prefix" {
  description = "Name prefix for the instance template resource"
  type        = string
  default     = "corelight-mig-template-"
}

variable "instance_template_group_manager_resource_name" {
  description = "Name of the instance group manager resource"
  type        = string
  default     = "corelight-mig-manager"
}

variable "instance_template_group_manager_base_instance_name" {
  description = "Base instance name to use for instances in this group"
  type        = string
  default     = "corelight"
}

variable "region_autoscaler_resource_name" {
  description = "Name of the autoscaler resource"
  type        = string
  default     = "corelight-autoscale"
}

variable "region_health_check_resource_name" {
  description = "Name of the health check resource"
  type        = string
  default     = "corelight-traffic-monitor-health-check"
}

variable "firewall_resource_name" {
  description = "Name of the sensor health check firewall rule"
  type        = string
  default     = "corelight-sensor-health-check-rule"
}

variable "region_backend_service_resource_name" {
  description = "Name of the region backend service resource"
  type        = string
  default     = "corelight-traffic-ilb-backend-service"
}

variable "forwarding_rule_resource_name" {
  description = "Name of the forwarding rule resource"
  type        = string
  default     = "corelight-traffic-forwarding-rule"
}

variable "packet_mirroring_resource_name" {
  description = "Name of the packet mirroring resource"
  type        = string
  default     = "corelight-traffic-mirroring"
}

variable "packet_mirror_network_tag" {
  description = "Packet mirror policy tag for mirrored resources"
  type        = string
  default     = "traffic-source"
}
