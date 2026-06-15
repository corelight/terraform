# Azure Sensor Single Module

Deploys a single Corelight sensor VM on Azure with management and monitoring network interfaces.

## Usage

```hcl
module "sensor" {
  source = "github.com/corelight/terraform//modules/azure/sensor-single?ref=v29.0.5-1"

  location            = "eastus"
  resource_group_name = "my-resource-group"

  corelight_sensor_image_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/images/corelight-sensor"
  sensor_ssh_public_key     = file("~/.ssh/id_rsa.pub")
  community_string          = var.community_string

  management_subnet_id = azurerm_subnet.management.id
  monitoring_subnet_id = azurerm_subnet.monitoring.id

  fleet_token          = var.fleet_token
  fleet_url            = var.fleet_url
  fleet_server_sslname = var.fleet_server_sslname

  tags = {
    Environment = "production"
  }
}
```

### With VNet Flow Log Access

```hcl
module "vnet_flow_access" {
  source = "github.com/corelight/terraform//modules/azure/sensor-single/submodules/vnet_flow_storage_access?ref=v29.0.5-1"

  resource_group_name = "my-resource-group"
  location            = "eastus"
  storage_account_id  = azurerm_storage_account.flow_logs.id
}

module "sensor" {
  source = "github.com/corelight/terraform//modules/azure/sensor-single?ref=v29.0.5-1"

  # ... other variables ...

  user_assigned_identity_ids = [module.vnet_flow_access.identity_id]
}
```

## Prerequisites

- A Corelight sensor image must be available in the subscription. Use [`scripts/azure/copy-azure-image.sh`](../../../scripts/azure/copy-azure-image.sh) to copy the VHD and create a VM image.
- The management subnet must have outbound internet access (via NAT gateway, Azure Firewall, or other mechanism) for Fleet connectivity.

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
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | The community string (API password) for sensor management, often referenced by Fleet | `string` | n/a | yes |
| <a name="input_corelight_sensor_image_id"></a> [corelight\_sensor\_image\_id](#input\_corelight\_sensor\_image\_id) | The resource ID of the Corelight sensor image | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed | `string` | n/a | yes |
| <a name="input_management_subnet_id"></a> [management\_subnet\_id](#input\_management\_subnet\_id) | The subnet ID for the management network interface | `string` | n/a | yes |
| <a name="input_monitoring_subnet_id"></a> [monitoring\_subnet\_id](#input\_monitoring\_subnet\_id) | The subnet ID for the monitoring network interface | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where resources will be deployed | `string` | n/a | yes |
| <a name="input_sensor_ssh_public_key"></a> [sensor\_ssh\_public\_key](#input\_sensor\_ssh\_public\_key) | The SSH public key which will be added to the sensor VM | `string` | n/a | yes |
| <a name="input_custom_sensor_user_data"></a> [custom\_sensor\_user\_data](#input\_custom\_sensor\_user\_data) | Custom user data for the sensor if the default doesn't apply | `string` | `""` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name prefix for all resources (used to avoid naming conflicts) | `string` | `"corelight-sensor"` | no |
| <a name="input_egress_allow_cidrs"></a> [egress\_allow\_cidrs](#input\_egress\_allow\_cidrs) | The IP ranges allowed outbound for both NICs. Typically can be left as default. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | (optional) the SSL hostname for the fleet server | `string` | `"1.broala.fleet.product.corelight.io"` | no |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | (optional) the pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | `""` | no |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | (optional) the URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | `""` | no |
| <a name="input_health_check_allow_cidrs"></a> [health\_check\_allow\_cidrs](#input\_health\_check\_allow\_cidrs) | CIDRs allowed to health check the sensor (port 41080) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_license_key"></a> [license\_key](#input\_license\_key) | Your Corelight sensor license key. Optional if fleet\_url is configured. | `string` | `""` | no |
| <a name="input_management_interface_public_ip"></a> [management\_interface\_public\_ip](#input\_management\_interface\_public\_ip) | Whether to assign a public IP to the management NIC | `bool` | `false` | no |
| <a name="input_management_nsg_id"></a> [management\_nsg\_id](#input\_management\_nsg\_id) | ID of a pre-existing NSG for the management NIC. If empty, one will be created. | `string` | `""` | no |
| <a name="input_monitoring_ingress_allow_cidrs"></a> [monitoring\_ingress\_allow\_cidrs](#input\_monitoring\_ingress\_allow\_cidrs) | CIDRs allowed to send mirrored traffic (VXLAN 4789) to the monitoring NIC | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_monitoring_nsg_id"></a> [monitoring\_nsg\_id](#input\_monitoring\_nsg\_id) | ID of a pre-existing NSG for the monitoring NIC. If empty, one will be created. | `string` | `""` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | The size of the OS disk in GB. Not recommended to set lower than 500GB | `number` | `500` | no |
| <a name="input_sensor_admin_username"></a> [sensor\_admin\_username](#input\_sensor\_admin\_username) | The admin username for the sensor VM | `string` | `"corelight"` | no |
| <a name="input_ssh_allow_cidrs"></a> [ssh\_allow\_cidrs](#input\_ssh\_allow\_cidrs) | List of CIDRs to grant SSH (port 22) access to the management NIC | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources deployed by this module | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | List of user-assigned managed identity IDs to attach to the VM (e.g. for VNet flow log access) | `list(string)` | `[]` | no |
| <a name="input_virtual_machine_size"></a> [virtual\_machine\_size](#input\_virtual\_machine\_size) | The Azure VM size for the sensor | `string` | `"Standard_D4s_v3"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_management_interface_id"></a> [management\_interface\_id](#output\_management\_interface\_id) | Network interface ID for management traffic |
| <a name="output_monitoring_interface_id"></a> [monitoring\_interface\_id](#output\_monitoring\_interface\_id) | Network interface ID for monitoring traffic |
| <a name="output_sensor_private_ip_address"></a> [sensor\_private\_ip\_address](#output\_sensor\_private\_ip\_address) | Private IP address of the management NIC |
| <a name="output_sensor_public_ip_address"></a> [sensor\_public\_ip\_address](#output\_sensor\_public\_ip\_address) | Public IP address of the management NIC (if enabled) |
| <a name="output_sensor_vm_id"></a> [sensor\_vm\_id](#output\_sensor\_vm\_id) | Resource ID of the sensor VM |
<!-- END_TF_DOCS -->
