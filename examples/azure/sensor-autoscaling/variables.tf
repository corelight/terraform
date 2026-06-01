variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for Corelight resources"
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

variable "management_subnet_cidr" {
  description = "CIDR block for the management subnet"
  type        = string
}

variable "monitoring_subnet_cidr" {
  description = "CIDR block for the monitoring subnet"
  type        = string
}

variable "corelight_sensor_image_id" {
  description = "Resource ID of the Corelight sensor image (request from your account executive)"
  type        = string
}

variable "sensor_ssh_public_key" {
  description = "SSH public key for sensor access"
  type        = string
}

variable "license_key" {
  description = "Corelight sensor license key (optional if using Fleet)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "community_string" {
  description = "Community string (API password) for sensor management"
  type        = string
  sensitive   = true
}

variable "fleet_token" {
  description = "Fleet pairing token from the Fleet UI (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "fleet_url" {
  description = "URL of the Fleet instance (optional)"
  type        = string
  default     = ""
}

variable "fleet_server_sslname" {
  description = "SSL hostname for the Fleet server (optional)"
  type        = string
  default     = ""
}

variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight"
}

variable "virtual_machine_size" {
  description = "Azure VM size for sensor instances"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "virtual_machine_os_disk_size" {
  description = "OS disk size in GB for sensor instances"
  type        = number
  default     = 500
}

variable "fedramp_mode_enabled" {
  description = "Enable FedRAMP mode"
  type        = bool
  default     = false
}

variable "prometheus_enabled" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = false
}

variable "azure_fips_enabled" {
  description = "Enable FIPS mode on Azure instances"
  type        = bool
  default     = false
}

variable "enrichment_storage_account_id" {
  description = "Resource ID of the enrichment storage account (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

