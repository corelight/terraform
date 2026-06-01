module "fleet_config" {
  source = "../../_shared/config/fleet"

  fleet_certificate    = file(var.fleet_certificate_file_path)
  fleet_sensor_license = file(var.fleet_sensor_license_file_path)
  community_string     = var.community_string
  fleet_password       = var.fleet_password
  fleet_username       = var.fleet_username

  # Optional - RADIUS
  radius_enable        = var.radius_enable
  radius_address       = var.radius_address
  radius_shared_secret = var.radius_shared_secret

  # Optional - Fleet Version
  fleet_version = var.fleet_version
}
