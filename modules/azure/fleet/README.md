# Azure Fleet Module

Deploys Corelight Fleet Manager on Azure as a single Linux VM behind a Standard public load balancer.

## Overview

This module creates:
- A Linux VM running Fleet Manager (installed via cloud-init from the Corelight package repo)
- A Standard public load balancer with rules for port 443 (web UI) and port 1443 (sensor API)
- A network security group with configurable ingress rules (optional — bring your own NSG supported)
- An Azure DNS A record pointing to the load balancer (optional)

## Usage

```hcl
module "fleet" {
  source = "github.com/corelight/terraform//modules/azure/fleet?ref=v29.0.5-1"

  location            = "eastus"
  resource_group_name = "my-resource-group"
  subnet_id           = azurerm_subnet.fleet.id

  ssh_public_key                 = file("~/.ssh/id_rsa.pub")
  community_string               = var.community_string
  fleet_username                 = "admin"
  fleet_password                 = var.fleet_password
  fleet_certificate_file_path    = "./fleet-cert.pem"
  fleet_sensor_license_file_path = "./fleet-license.txt"
  corelight_package_repo_token   = var.corelight_package_repo_token

  # Optional — DNS
  dns_zone_name                = "example.com"
  dns_zone_resource_group_name = "dns-rg"

  # Optional — SSH admin access
  admin_cidr_blocks = ["203.0.113.0/24"]

  tags = {
    Environment = "production"
  }
}
```

## Network Architecture

The module creates a public-facing Standard load balancer that forwards traffic to the Fleet VM:

- **Port 443** — Fleet Manager web UI (HTTPS, handled by Fleet)
- **Port 1443** — Fleet sensor API (HTTPS, used for sensor pairing and management)

TLS termination happens at the Fleet service itself — the load balancer performs TCP passthrough.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | Fleet community string for sensor pairing | `string` | n/a | yes |
| <a name="input_fleet_certificate_file_path"></a> [fleet\_certificate\_file\_path](#input\_fleet\_certificate\_file\_path) | Path to the Fleet certificate file | `string` | n/a | yes |
| <a name="input_fleet_password"></a> [fleet\_password](#input\_fleet\_password) | Fleet admin password | `string` | n/a | yes |
| <a name="input_fleet_sensor_license_file_path"></a> [fleet\_sensor\_license\_file\_path](#input\_fleet\_sensor\_license\_file\_path) | Path to the Fleet sensor license file | `string` | n/a | yes |
| <a name="input_fleet_username"></a> [fleet\_username](#input\_fleet\_username) | Fleet admin username | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where resources will be deployed | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for Fleet VM access | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID where the Fleet VM will be deployed | `string` | n/a | yes |
| <a name="input_admin_cidr_blocks"></a> [admin\_cidr\_blocks](#input\_admin\_cidr\_blocks) | List of CIDR blocks for SSH admin access to the Fleet VM. If empty, no SSH rule is created. | `list(string)` | `[]` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username for the Fleet VM | `string` | `"corelight"` | no |
| <a name="input_api_ingress_cidr_blocks"></a> [api\_ingress\_cidr\_blocks](#input\_api\_ingress\_cidr\_blocks) | List of CIDR blocks allowed to access Fleet sensor API on port 1443 | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_corelight_package_repo_token"></a> [corelight\_package\_repo\_token](#input\_corelight\_package\_repo\_token) | Authentication token for the Corelight package repository (from https://my.corelight.cloud/). If not set, falls back to the legacy public repository. | `string` | `""` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name prefix for all resources (used to avoid naming conflicts) | `string` | `"corelight-fleet"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | The name of an existing Azure DNS zone (e.g., example.com). If not set, DNS record creation is skipped. | `string` | `null` | no |
| <a name="input_dns_zone_resource_group_name"></a> [dns\_zone\_resource\_group\_name](#input\_dns\_zone\_resource\_group\_name) | The resource group containing the Azure DNS zone. Required if dns\_zone\_name is set. | `string` | `null` | no |
| <a name="input_fleet_image_id"></a> [fleet\_image\_id](#input\_fleet\_image\_id) | Optional: custom image ID for the Fleet VM. If not set, Ubuntu 22.04 LTS from Canonical is used. | `string` | `null` | no |
| <a name="input_fleet_version"></a> [fleet\_version](#input\_fleet\_version) | The version of Fleet to deploy | `string` | `"28.2.2"` | no |
| <a name="input_https_ingress_cidr_blocks"></a> [https\_ingress\_cidr\_blocks](#input\_https\_ingress\_cidr\_blocks) | List of CIDR blocks allowed to access Fleet web UI on port 443 | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_nsg_id"></a> [nsg\_id](#input\_nsg\_id) | ID of a pre-existing NSG for the Fleet VM NIC. If empty, one will be created. | `string` | `""` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Root OS disk size in GB | `number` | `50` | no |
| <a name="input_radius_address"></a> [radius\_address](#input\_radius\_address) | RADIUS server address and port (e.g., 1.2.3.4:1812). Required if RADIUS is enabled. | `string` | `""` | no |
| <a name="input_radius_enable"></a> [radius\_enable](#input\_radius\_enable) | Enable RADIUS authentication | `bool` | `false` | no |
| <a name="input_radius_shared_secret"></a> [radius\_shared\_secret](#input\_radius\_shared\_secret) | RADIUS shared secret. Required if RADIUS is enabled. | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain for Fleet to be prefixed to the DNS zone name (e.g., fleet) | `string` | `"fleet"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources deployed by this module | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size for the Fleet instance | `string` | `"Standard_D2s_v5"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_fleet_fqdn"></a> [fleet\_fqdn](#output\_fleet\_fqdn) | The fully qualified domain name for Fleet (if DNS is configured) |
| <a name="output_fleet_private_ip"></a> [fleet\_private\_ip](#output\_fleet\_private\_ip) | Private IP address of the Fleet VM |
| <a name="output_fleet_public_ip"></a> [fleet\_public\_ip](#output\_fleet\_public\_ip) | The public IP address of the Fleet load balancer |
| <a name="output_fleet_vm_id"></a> [fleet\_vm\_id](#output\_fleet\_vm\_id) | Resource ID of the Fleet VM |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | Resource ID of the Fleet load balancer |
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | The NSG ID in use (created or provided) |
<!-- END_TF_DOCS -->
