# Deployment

variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight-fleet"
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be deployed"
  type        = string
}

# Networking

variable "subnet_id" {
  description = "The subnet ID where the Fleet VM will be deployed"
  type        = string
}

# DNS — optional, set dns_zone_name to enable Azure DNS integration

variable "dns_zone_name" {
  description = "The name of an existing Azure DNS zone (e.g., example.com). If not set, DNS record creation is skipped."
  type        = string
  default     = null
}

variable "dns_zone_resource_group_name" {
  description = "The resource group containing the Azure DNS zone. Required if dns_zone_name is set."
  type        = string
  default     = null
}

variable "subdomain" {
  description = "Subdomain for Fleet to be prefixed to the DNS zone name (e.g., fleet)"
  type        = string
  default     = "fleet"
}

# NSG — optional, leave empty to create a default NSG

variable "nsg_id" {
  description = "ID of a pre-existing NSG for the Fleet VM NIC. If empty, one will be created."
  type        = string
  default     = ""
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Fleet web UI on port 443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "api_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Fleet sensor API on port 1443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidr_blocks" {
  description = "List of CIDR blocks for SSH admin access to the Fleet VM. If empty, no SSH rule is created."
  type        = list(string)
  default     = []
}

# VM configuration

variable "ssh_public_key" {
  description = "SSH public key for Fleet VM access"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the Fleet VM"
  type        = string
  default     = "corelight"
}

variable "fleet_image_id" {
  description = "Optional: custom image ID for the Fleet VM. If not set, Ubuntu 22.04 LTS from Canonical is used."
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Azure VM size for the Fleet instance"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "os_disk_size_gb" {
  description = "Root OS disk size in GB"
  type        = number
  default     = 50
}

# Fleet Configuration

variable "community_string" {
  description = "Fleet community string for sensor pairing"
  type        = string
  sensitive   = true
}

variable "fleet_username" {
  description = "Fleet admin username"
  type        = string
}

variable "fleet_password" {
  description = "Fleet admin password"
  type        = string
  sensitive   = true
}

variable "fleet_certificate_file_path" {
  description = "Path to the Fleet certificate file"
  type        = string
}

variable "fleet_sensor_license_file_path" {
  description = "Path to the Fleet sensor license file"
  type        = string
}

variable "fleet_version" {
  description = "The version of Fleet to deploy"
  type        = string
  default     = "28.2.2"
}

variable "corelight_package_repo_token" {
  description = "Authentication token for the Corelight package repository (from https://my.corelight.cloud/). If not set, falls back to the legacy public repository."
  type        = string
  sensitive   = true
  default     = ""
}

# RADIUS Authentication

variable "radius_enable" {
  description = "Enable RADIUS authentication"
  type        = bool
  default     = false
}

variable "radius_address" {
  description = "RADIUS server address and port (e.g., 1.2.3.4:1812). Required if RADIUS is enabled."
  type        = string
  default     = ""
}

variable "radius_shared_secret" {
  description = "RADIUS shared secret. Required if RADIUS is enabled."
  type        = string
  default     = ""
  sensitive   = true
}

# Tags

variable "tags" {
  description = "Tags to apply to all resources deployed by this module"
  type        = map(string)
  default     = {}
}
