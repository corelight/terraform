variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for Fleet resources"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "virtual_network_resource_group" {
  description = "Resource group containing the existing virtual network"
  type        = string
}

variable "fleet_subnet_cidr" {
  description = "CIDR block for the Fleet subnet"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for Fleet VM access"
  type        = string
}

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

variable "corelight_package_repo_token" {
  description = "Authentication token for the Corelight package repository (from https://my.corelight.cloud/)"
  type        = string
  sensitive   = true
}

variable "deployment_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "corelight-fleet"
}

variable "vm_size" {
  description = "Azure VM size for the Fleet instance"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "dns_zone_name" {
  description = "Azure DNS zone name for Fleet DNS record (optional)"
  type        = string
  default     = null
}

variable "dns_zone_resource_group_name" {
  description = "Resource group containing the Azure DNS zone (required if dns_zone_name is set)"
  type        = string
  default     = null
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks for SSH admin access (optional)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
