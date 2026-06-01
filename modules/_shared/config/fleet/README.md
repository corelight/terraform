# Fleet Configuration Module

Terraform module for generating Corelight Fleet Manager cloud-init configuration.

## Description

This shared module generates cloud-init configuration for Corelight Fleet Manager deployments across AWS, GCP, and Azure. It is used internally by cloud-specific Fleet modules.

## Usage

### Internal Module Reference

This module is designed for internal use within the monorepo. Cloud-specific Fleet modules should reference it using relative paths:

```terraform
# From a cloud-specific fleet module (e.g., aws/fleet, gcp/fleet, azure/fleet)
module "fleet_config" {
  source = "../../_shared/config/fleet"

  fleet_version        = var.fleet_version
  fleet_certificate    = var.fleet_certificate
  fleet_sensor_license = var.fleet_sensor_license
  community_string     = var.community_string
  fleet_password       = var.fleet_password
  fleet_username       = var.fleet_username

  # Optional - RADIUS Authentication
  radius_enable        = var.radius_enable
  radius_address       = var.radius_address
  radius_shared_secret = var.radius_shared_secret

  # Config encoding options
  base64_encode_config = true
  gzip_config          = false
}
```

### External User Reference

Users should not reference this module directly. Instead, use the cloud-specific Fleet modules:

```terraform
# AWS Fleet Manager
module "fleet" {
  source = "github.com/corelight/terraform//modules/aws/fleet?ref=v28.4.0-1"
  # ...
}
```

## Features

- Automated Fleet Manager installation via cloud-init
- Support for both Debian (apt) and RedHat (dnf) based distributions
- Certificate and license file deployment
- Initial user creation with configurable credentials
- Optional RADIUS authentication integration
- Configurable output encoding (base64, gzip)

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
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | community string for sensor pairing | `string` | n/a | yes |
| <a name="input_fleet_certificate"></a> [fleet\_certificate](#input\_fleet\_certificate) | Base64-encoded Fleet certificate | `string` | n/a | yes |
| <a name="input_fleet_password"></a> [fleet\_password](#input\_fleet\_password) | Password for the Fleet user | `string` | n/a | yes |
| <a name="input_fleet_sensor_license"></a> [fleet\_sensor\_license](#input\_fleet\_sensor\_license) | Base64-encoded Fleet sensor license | `string` | n/a | yes |
| <a name="input_fleet_username"></a> [fleet\_username](#input\_fleet\_username) | Username for the Fleet user | `string` | n/a | yes |
| <a name="input_base64_encode_config"></a> [base64\_encode\_config](#input\_base64\_encode\_config) | should the configuration be base64 encoded | `bool` | `false` | no |
| <a name="input_fleet_version"></a> [fleet\_version](#input\_fleet\_version) | Fleet Manager version to install (e.g., 28.2.2) | `string` | `"28.2.2"` | no |
| <a name="input_gzip_config"></a> [gzip\_config](#input\_gzip\_config) | should the configuration be gzipped | `bool` | `false` | no |
| <a name="input_radius_address"></a> [radius\_address](#input\_radius\_address) | RADIUS server address and port (e.g., 1.2.3.4:1812) | `string` | `""` | no |
| <a name="input_radius_enable"></a> [radius\_enable](#input\_radius\_enable) | Enable RADIUS authentication | `bool` | `false` | no |
| <a name="input_radius_shared_secret"></a> [radius\_shared\_secret](#input\_radius\_shared\_secret) | RADIUS shared secret | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudinit_config"></a> [cloudinit\_config](#output\_cloudinit\_config) | n/a |
<!-- END_TF_DOCS -->
