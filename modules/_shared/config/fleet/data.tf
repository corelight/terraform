data "cloudinit_config" "config" {
  gzip          = var.gzip_config
  base64_encode = var.base64_encode_config

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
      fleet_version        = var.fleet_version
      fleet_certificate    = base64encode(var.fleet_certificate)
      fleet_sensor_license = base64encode(var.fleet_sensor_license)
      community_string     = var.community_string
      fleet_password       = var.fleet_password
      fleet_username       = var.fleet_username

      radius_enable        = var.radius_enable
      radius_address       = var.radius_address
      radius_shared_secret = var.radius_shared_secret
    })
    filename = "fleet-init.yaml"
  }
}
