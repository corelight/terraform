# Deployment

variable "deployment_name" {
  description = "Name prefix for shared resources (ILB, NSGs). Each sensor is named by its manifest key."
  type        = string
  default     = "corelight"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create for sensor resources"
  type        = string
}

# Networking — VNet and subnets must already exist

variable "virtual_network_name" {
  description = "Name of the existing VNet"
  type        = string
}

variable "virtual_network_resource_group" {
  description = "Resource group of the existing VNet"
  type        = string
}

variable "management_subnet_cidr" {
  description = "CIDR for the management subnet (created by this example)"
  type        = string
}

variable "monitoring_subnet_cidr" {
  description = "CIDR for the monitoring subnet (created by this example)"
  type        = string
}

# Sensor image

variable "corelight_sensor_image_id" {
  description = "Resource ID of the Corelight sensor VM image (shared across all sensors unless overridden per-sensor in sensors.json)"
  type        = string
}

variable "sensor_ssh_public_key" {
  description = "SSH public key added to all sensor VMs"
  type        = string
}

# Fleet configuration

variable "fleet_url" {
  description = "Fleet instance URL (e.g. https://fleet.example.com:1443)"
  type        = string
}

variable "fleet_server_sslname" {
  description = "TLS hostname for Fleet server certificate verification"
  type        = string
  default     = "1.broala.fleet.product.corelight.io"
}

variable "community_string" {
  description = "Community string (API password) shared by all sensors"
  type        = string
  sensitive   = true
}

# Optional settings

variable "virtual_machine_size" {
  description = "Azure VM size for the sensors"
  type        = string
  default     = "Standard_D8s_v7"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 500
}

variable "ssh_allow_cidrs" {
  description = "CIDRs allowed SSH access to the management NIC"
  type        = list(string)
  default     = []
}

variable "monitoring_ingress_allow_cidrs" {
  description = "CIDRs allowed to send mirrored traffic (VXLAN 4789) to the monitoring NIC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
