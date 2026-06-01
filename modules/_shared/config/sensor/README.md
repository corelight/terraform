# terraform-config-sensor

Terraform for Corelight's Sensor Configuration.

## Usage

```terraform
module "sensor_config" {
  source = "github.com/corelight/terraform-config-sensor"

  fleet_community_string                       = "<your Corelight Fleet community string>"
  sensor_license                               = "<your Corelight sensor license key>"
  sensor_management_interface_name             = "<the instance's management interface name>"
  sensor_monitoring_interface_name             = "<the instance's monitoring interface name>"
  sensor_health_check_probe_source_ranges_cidr = "<the cloud provider's health check source CIDR>"
  subnetwork_monitoring_cidr                   = "<the instance's monitoring subnetwork CIDR>"
  subnetwork_monitoring_gateway                = "<the instance's monitoring subnetwork gateway IP>"

  # Optional - Fleet Manager
  fleet_token = "b1cd099ff22ed8a41abc63929d1db126"
  fleet_url   = "https://fleet.example.com:1443/fleet/v1/internal/softsensor/websocket"
  fleet_server_sslname = "foo.example.com"
}
```

## Deployment

The variables for this module all have default values that can be overwritten
to meet your naming and compliance standards.

Deployment examples can be found [here](examples).

## License

The project is licensed under the MIT license.

[MIT]: LICENSE

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.3.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_fleet_community_string"></a> [fleet\_community\_string](#input\_fleet\_community\_string) | the Fleet Manager community string (api string) | `string` | n/a | yes |
| <a name="input_sensor_license"></a> [sensor\_license](#input\_sensor\_license) | path to the Corelight sensor license file | `string` | n/a | yes |
| <a name="input_sensor_management_interface_name"></a> [sensor\_management\_interface\_name](#input\_sensor\_management\_interface\_name) | the sensor(s) management interface name | `string` | n/a | yes |
| <a name="input_sensor_monitoring_interface_name"></a> [sensor\_monitoring\_interface\_name](#input\_sensor\_monitoring\_interface\_name) | the sensor(s) monitoring interface name | `string` | n/a | yes |
| <a name="input_azure_fips_enabled"></a> [azure\_fips\_enabled](#input\_azure\_fips\_enabled) | (optional) enable FIPS mode on Azure instances | `bool` | `false` | no |
| <a name="input_base64_encode_config"></a> [base64\_encode\_config](#input\_base64\_encode\_config) | should the configuration be base64 encoded | `bool` | `false` | no |
| <a name="input_fedramp_mode_enabled"></a> [fedramp\_mode\_enabled](#input\_fedramp\_mode\_enabled) | (optional) enable Fedramp mode | `bool` | `false` | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | the SSL hostname for the fleet server | `string` | `""` | no |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | The pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | `""` | no |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | The URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | `""` | no |
| <a name="input_gzip_config"></a> [gzip\_config](#input\_gzip\_config) | should the configuration be gzipped | `bool` | `false` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | (optional) enable Prometheus metrics | `bool` | `false` | no |
| <a name="input_sensor_health_check_http_port"></a> [sensor\_health\_check\_http\_port](#input\_sensor\_health\_check\_http\_port) | the port number for the HTTP health check request | `string` | `"41080"` | no |
| <a name="input_sensor_health_check_probe_source_ranges_cidr"></a> [sensor\_health\_check\_probe\_source\_ranges\_cidr](#input\_sensor\_health\_check\_probe\_source\_ranges\_cidr) | (optional) the health check probe ranges | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_subnetwork_monitoring_cidr"></a> [subnetwork\_monitoring\_cidr](#input\_subnetwork\_monitoring\_cidr) | (optional) the monitoring subnet for the sensor(s), leaving this empty will result in no sensor.monitoring\_interface.health\_check section being rendered into user data | `string` | `""` | no |
| <a name="input_subnetwork_monitoring_gateway"></a> [subnetwork\_monitoring\_gateway](#input\_subnetwork\_monitoring\_gateway) | (optional) the monitoring subnet's gateway address, leaving this empty will result in no sensor.monitoring\_interface.health\_check section being rendered into user data | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudinit_config"></a> [cloudinit\_config](#output\_cloudinit\_config) | n/a |
<!-- END_TF_DOCS -->