variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight-sensor"
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be deployed"
  type        = string
}

variable "corelight_sensor_image_id" {
  description = "The resource ID of the Corelight sensor image"
  type        = string
}

variable "sensor_ssh_public_key" {
  description = "The SSH public key which will be added to the sensor VM"
  type        = string
}

variable "community_string" {
  description = "The community string (API password) for sensor management"
  type        = string
  sensitive   = true
}

variable "management_subnet_id" {
  description = "The subnet ID for the management network interface"
  type        = string
}

variable "monitoring_subnet_id" {
  description = "The subnet ID for the monitoring network interface"
  type        = string
}

variable "license_key" {
  description = "Your Corelight sensor license key. Optional if fleet_url is configured."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.license_key != "" || var.fleet_url != ""
    error_message = "Either license_key must be provided or fleet_url must be configured."
  }
}

variable "fleet_token" {
  description = "(optional) the pairing token from the Fleet UI. Must be set if 'fleet_url' is provided"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fleet_url" {
  description = "(optional) the URL of the fleet instance from the Fleet UI. Must be set if 'fleet_token' is provided"
  type        = string
  default     = ""
}

variable "fleet_server_sslname" {
  description = "(optional) the SSL hostname for the fleet server"
  type        = string
  default     = "1.broala.fleet.product.corelight.io"
}

variable "fleet_http_proxy" {
  description = "(optional) the proxy URL for HTTP traffic from the fleet"
  type        = string
  default     = ""
}

variable "fleet_https_proxy" {
  description = "(optional) the proxy URL for HTTPS traffic from the fleet"
  type        = string
  default     = ""
}

variable "fleet_no_proxy" {
  description = "(optional) hosts or domains to bypass the proxy for fleet traffic"
  type        = string
  default     = ""
}

# VM configuration

variable "sensor_admin_username" {
  description = "The admin username for the sensor VM"
  type        = string
  default     = "corelight"
}

variable "virtual_machine_size" {
  description = "The Azure VM size for the sensor"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB. Not recommended to set lower than 500GB"
  type        = number
  default     = 500
}

variable "custom_sensor_user_data" {
  description = "Custom user data for the sensor if the default doesn't apply"
  type        = string
  default     = ""
}

# Networking

variable "management_nsg_id" {
  description = "ID of a pre-existing NSG for the management NIC. If empty, one will be created."
  type        = string
  default     = ""
}

variable "monitoring_nsg_id" {
  description = "ID of a pre-existing NSG for the monitoring NIC. If empty, one will be created."
  type        = string
  default     = ""
}

variable "management_interface_public_ip" {
  description = "Whether to assign a public IP to the management NIC"
  type        = bool
  default     = false
}

variable "egress_allow_cidrs" {
  description = "The IP ranges allowed outbound for both NICs. Typically can be left as default."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allow_cidrs" {
  description = "List of CIDRs to grant SSH (port 22) access to the management NIC"
  type        = list(string)
  default     = []
}

variable "monitoring_ingress_allow_cidrs" {
  description = "CIDRs allowed to send mirrored traffic (VXLAN 4789) to the monitoring NIC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "health_check_allow_cidrs" {
  description = "CIDRs allowed to health check the sensor (port 41080)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Identity

variable "user_assigned_identity_ids" {
  description = "List of user-assigned managed identity IDs to attach to the VM (e.g. for VNet flow log access)"
  type        = list(string)
  default     = []
}

# Tags

variable "tags" {
  description = "Tags to apply to all resources deployed by this module"
  type        = map(string)
  default     = {}
}
