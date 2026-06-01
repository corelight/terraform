# Azure Sensor

Auto-scaling Corelight sensor deployment on Azure via a Virtual Machine Scale Set with internal load balancer and NAT gateway.

## Usage

```hcl
module "sensor" {
  source = "github.com/corelight/terraform//modules/azure/sensor?ref=v28.4.0-1"

  location                  = "eastus"
  resource_group_name       = "corelight-rg"
  management_subnet_id      = "/subscriptions/.../subnets/management"
  monitoring_subnet_id      = "/subscriptions/.../subnets/monitoring"
  corelight_sensor_image_id = "/subscriptions/.../images/corelight-sensor"
  community_string          = "your-community-string"
  sensor_ssh_public_key     = file("~/.ssh/id_rsa.pub")

  fleet_token          = "your-fleet-token"
  fleet_url            = "https://fleet.example.com:1443/..."
  fleet_server_sslname = "fleet.example.com"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | the community string (api string) often times referenced by Fleet | `string` | n/a | yes |
| <a name="input_corelight_sensor_image_id"></a> [corelight\_sensor\_image\_id](#input\_corelight\_sensor\_image\_id) | The resource id of Corelight sensor image | `string` | n/a | yes |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | SSL hostname for the fleet server | `string` | n/a | yes |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | The pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | n/a | yes |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where resources will be deployed | `string` | n/a | yes |
| <a name="input_management_subnet_id"></a> [management\_subnet\_id](#input\_management\_subnet\_id) | The subnet used to access the sensor | `string` | n/a | yes |
| <a name="input_monitoring_subnet_id"></a> [monitoring\_subnet\_id](#input\_monitoring\_subnet\_id) | The subnet used for monitoring traffic | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where corelight resources will be deployed | `string` | n/a | yes |
| <a name="input_sensor_ssh_public_key"></a> [sensor\_ssh\_public\_key](#input\_sensor\_ssh\_public\_key) | The SSH public key which will be added to all sensors in the scale set | `string` | n/a | yes |
| <a name="input_autoscale_setting_name"></a> [autoscale\_setting\_name](#input\_autoscale\_setting\_name) | The VMSS autoscale monitor name | `string` | `"corelight-scale-set-autoscale-cfg"` | no |
| <a name="input_azure_fips_enabled"></a> [azure\_fips\_enabled](#input\_azure\_fips\_enabled) | (optional) enable FIPS mode on Azure instances | `bool` | `false` | no |
| <a name="input_fedramp_mode_enabled"></a> [fedramp\_mode\_enabled](#input\_fedramp\_mode\_enabled) | (optional) enable Fedramp mode | `bool` | `false` | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_lb_management_frontend_ip_config_name"></a> [lb\_management\_frontend\_ip\_config\_name](#input\_lb\_management\_frontend\_ip\_config\_name) | Name of the internal load balancer management backend pool frontend ip configuration | `string` | `"corelight-management"` | no |
| <a name="input_lb_management_probe_name"></a> [lb\_management\_probe\_name](#input\_lb\_management\_probe\_name) | Name of the load balancer health probe that checks if SSH is available on the management NIC | `string` | `"ssh-health-check"` | no |
| <a name="input_lb_mgmt_backend_address_pool_name"></a> [lb\_mgmt\_backend\_address\_pool\_name](#input\_lb\_mgmt\_backend\_address\_pool\_name) | Name of the load balancer management backend address pool | `string` | `"management-pool"` | no |
| <a name="input_lb_mon_backend_address_pool_name"></a> [lb\_mon\_backend\_address\_pool\_name](#input\_lb\_mon\_backend\_address\_pool\_name) | Name of the load balancer monitoring backend address pool | `string` | `"monitoring-pool"` | no |
| <a name="input_lb_monitoring_frontend_ip_config_name"></a> [lb\_monitoring\_frontend\_ip\_config\_name](#input\_lb\_monitoring\_frontend\_ip\_config\_name) | Name of the internal load balancer monitoring backend pool frontend ip configuration | `string` | `"corelight-monitoring"` | no |
| <a name="input_lb_monitoring_probe_name"></a> [lb\_monitoring\_probe\_name](#input\_lb\_monitoring\_probe\_name) | Name of the load balancer health check probe that checks if the sensor is up and ready to receive traffic on the monitoring NIC | `string` | `"sensor-health-check"` | no |
| <a name="input_lb_ssh_rule_name"></a> [lb\_ssh\_rule\_name](#input\_lb\_ssh\_rule\_name) | Name of the load balancer rule for SSH traffic | `string` | `"management-ssh-lb-rule"` | no |
| <a name="input_lb_vxlan_rule_name"></a> [lb\_vxlan\_rule\_name](#input\_lb\_vxlan\_rule\_name) | Name of the load balancer rule for VXLAN traffic | `string` | `"vxlan-lb-rule"` | no |
| <a name="input_license_key"></a> [license\_key](#input\_license\_key) | Your Corelight sensor license key. Optional if fleet\_url is configured. | `string` | `""` | no |
| <a name="input_load_balancer_name"></a> [load\_balancer\_name](#input\_load\_balancer\_name) | The name of the internal load balancer that sends traffic to the VMSS | `string` | `"corelight-sensor-lb"` | no |
| <a name="input_nat_gateway_ip_name"></a> [nat\_gateway\_ip\_name](#input\_nat\_gateway\_ip\_name) | The resource name of the VMSS NAT Gateway public IP resource | `string` | `"cl-nat-gw-ip"` | no |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | The resource name of the VMSS NAT Gateway resource | `string` | `"cl-sensor-nat-gw"` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | (optional) enable Prometheus metrics | `bool` | `false` | no |
| <a name="input_scale_set_name"></a> [scale\_set\_name](#input\_scale\_set\_name) | Name of the Corelight VMSS of sensors | `string` | `"corelight-sensor"` | no |
| <a name="input_sensor_admin_username"></a> [sensor\_admin\_username](#input\_sensor\_admin\_username) | The name of the admin user on the corelight sensor VM in the VMSS | `string` | `"corelight"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Any tags that should be applied to resources deployed by the module | `map(string)` | `{}` | no |
| <a name="input_virtual_machine_os_disk_size"></a> [virtual\_machine\_os\_disk\_size](#input\_virtual\_machine\_os\_disk\_size) | The amount of OS disk to attach to the VMSS instances | `number` | `500` | no |
| <a name="input_virtual_machine_size"></a> [virtual\_machine\_size](#input\_virtual\_machine\_size) | The VMSS VM size | `string` | `"Standard_D4s_v3"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_internal_load_balancer_name"></a> [internal\_load\_balancer\_name](#output\_internal\_load\_balancer\_name) | n/a |
| <a name="output_nat_gateway_name"></a> [nat\_gateway\_name](#output\_nat\_gateway\_name) | n/a |
| <a name="output_nat_gateway_public_ip_name"></a> [nat\_gateway\_public\_ip\_name](#output\_nat\_gateway\_public\_ip\_name) | n/a |
| <a name="output_sensor_identity_principal_id"></a> [sensor\_identity\_principal\_id](#output\_sensor\_identity\_principal\_id) | n/a |
| <a name="output_sensor_load_balancer_management_frontend_ip_address"></a> [sensor\_load\_balancer\_management\_frontend\_ip\_address](#output\_sensor\_load\_balancer\_management\_frontend\_ip\_address) | n/a |
| <a name="output_sensor_load_balancer_monitoring_frontend_ip_address"></a> [sensor\_load\_balancer\_monitoring\_frontend\_ip\_address](#output\_sensor\_load\_balancer\_monitoring\_frontend\_ip\_address) | n/a |
| <a name="output_sensor_scale_set_name"></a> [sensor\_scale\_set\_name](#output\_sensor\_scale\_set\_name) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
