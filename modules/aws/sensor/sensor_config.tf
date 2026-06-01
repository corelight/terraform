module "sensor_config" {
  source = "../../_shared/config/sensor"

  sensor_license                   = var.license_key_file_path != "" ? file(var.license_key_file_path) : ""
  fleet_community_string           = var.community_string
  fleet_token                      = var.fleet_token
  fleet_url                        = var.fleet_url
  fleet_server_sslname             = var.fleet_server_sslname
  fleet_http_proxy                 = var.fleet_http_proxy
  fleet_https_proxy                = var.fleet_https_proxy
  fleet_no_proxy                   = var.fleet_no_proxy
  sensor_management_interface_name = "eth1"
  sensor_monitoring_interface_name = "eth0"
  base64_encode_config             = true
  sensor_health_check_http_port    = tostring(var.sensor_health_check_http_port)
}
