data "external" "fleet_token" {
  program = ["bash", "${path.module}/get_fleet_token.sh"]

  query = {
    fleet_url            = local.fleet_url
    fleet_username       = var.fleet_username
    fleet_password       = var.fleet_password
    sensor_instance_name = var.sensor_instance_name
  }

  depends_on = [null_resource.fleet_delay]
}
