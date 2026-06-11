variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight-vnet-flow-sensor"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The resource group where all resources will be deployed"
  type        = string
}

variable "corelight_sensor_image_id" {
  description = "The resource ID of the Corelight sensor image"
  type        = string
}

variable "sensor_ssh_public_key" {
  description = "SSH public key content for the sensor VM"
  type        = string
}

variable "community_string" {
  description = "Community string (API password) for sensor management"
  type        = string
  sensitive   = true
}

# Licensing (Choose ONE option)

variable "license_key" {
  description = "Corelight sensor license key. Optional if fleet_url is configured."
  type        = string
  sensitive   = true
  default     = ""
}

variable "fleet_token" {
  description = "Fleet pairing token from the Fleet UI"
  type        = string
  sensitive   = true
  default     = ""
}

variable "fleet_url" {
  description = "URL of the Fleet instance"
  type        = string
  default     = ""
}

variable "fleet_server_sslname" {
  description = "SSL hostname for the Fleet server"
  type        = string
  default     = ""
}

# Network Configuration

variable "management_subnet_id" {
  description = "Subnet ID for the management network interface"
  type        = string
}

variable "monitoring_subnet_id" {
  description = "Subnet ID for the monitoring network interface"
  type        = string
}

variable "management_interface_public_ip" {
  description = "Whether to associate a public IP with the management interface"
  type        = bool
  default     = false
}

variable "ssh_allow_cidrs" {
  description = "CIDR blocks allowed to SSH to the flow sensor"
  type        = list(string)
  default     = []
}

# VNet Flow Logs Configuration

variable "storage_account_id" {
  description = "The resource ID of the storage account containing VNet flow logs"
  type        = string
}

# Tags

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
