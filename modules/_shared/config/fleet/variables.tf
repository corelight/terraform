variable "fleet_version" {
  description = "Fleet Manager version to install (e.g., 28.2.2)"
  type        = string
  default     = "28.2.2"
}

variable "fleet_certificate" {
  description = "Base64-encoded Fleet certificate"
  type        = string
}

variable "fleet_sensor_license" {
  description = "Base64-encoded Fleet sensor license"
  type        = string
}

variable "community_string" {
  description = "community string for sensor pairing"
  type        = string
  sensitive   = true
}

variable "fleet_password" {
  description = "Password for the Fleet user"
  type        = string
  sensitive   = true
}

variable "fleet_username" {
  description = "Username for the Fleet user"
  type        = string
}

variable "radius_enable" {
  description = "Enable RADIUS authentication"
  type        = bool
  default     = false
}

variable "radius_address" {
  description = "RADIUS server address and port (e.g., 1.2.3.4:1812)"
  type        = string
  default     = ""
}

variable "radius_shared_secret" {
  description = "RADIUS shared secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gzip_config" {
  type        = bool
  default     = false
  description = "should the configuration be gzipped"
}

variable "base64_encode_config" {
  type        = bool
  default     = false
  description = "should the configuration be base64 encoded"
}
