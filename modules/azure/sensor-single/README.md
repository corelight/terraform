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

- The management subnet must have outbound internet access (via NAT gateway, Azure Firewall, or other mechanism) for Fleet connectivity.
- A Corelight sensor image must be available in the subscription.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| azurerm | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | -------- |
| deployment\_name | Name prefix for all resources | `string` | `"corelight-sensor"` | no |
| location | The Azure region where resources will be deployed | `string` | n/a | yes |
| resource\_group\_name | The name of the resource group | `string` | n/a | yes |
| corelight\_sensor\_image\_id | The resource ID of the Corelight sensor image | `string` | n/a | yes |
| sensor\_ssh\_public\_key | SSH public key for the sensor VM | `string` | n/a | yes |
| community\_string | The community string (API password) | `string` | n/a | yes |
| management\_subnet\_id | Subnet ID for the management NIC | `string` | n/a | yes |
| monitoring\_subnet\_id | Subnet ID for the monitoring NIC | `string` | n/a | yes |
| license\_key | Corelight sensor license key (optional if fleet\_url is set) | `string` | `""` | no |
| fleet\_token | Fleet pairing token | `string` | `""` | no |
| fleet\_url | Fleet URL | `string` | `""` | no |
| virtual\_machine\_size | Azure VM size | `string` | `"Standard_D4s_v3"` | no |
| os\_disk\_size\_gb | OS disk size in GB | `number` | `500` | no |
| user\_assigned\_identity\_ids | Managed identity IDs to attach (e.g. for VNet flow log access) | `list(string)` | `[]` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| sensor\_vm\_id | Resource ID of the sensor VM |
| sensor\_private\_ip\_address | Private IP of the management NIC |
| sensor\_public\_ip\_address | Public IP of the management NIC (if enabled) |
| management\_interface\_id | Network interface ID for management |
| monitoring\_interface\_id | Network interface ID for monitoring |
<!-- END_TF_DOCS -->
