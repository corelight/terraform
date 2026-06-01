# EventBridge Cross-Region IAM

IAM role and policy granting EventBridge permission to forward events to the primary event bus across regions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.45.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.45.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_primary_event_bus_arn"></a> [primary\_event\_bus\_arn](#input\_primary\_event\_bus\_arn) | ARN of the primary event bus that all events will fan-in to | `string` | n/a | yes |
| <a name="input_cross_region_event_bus_policy_name"></a> [cross\_region\_event\_bus\_policy\_name](#input\_cross\_region\_event\_bus\_policy\_name) | Name of the Corelight Event Bus | `string` | `"corelight-primary-event-bus-policy"` | no |
| <a name="input_cross_region_event_bus_role_name"></a> [cross\_region\_event\_bus\_role\_name](#input\_cross\_region\_event\_bus\_role\_name) | Name of the IAM Role granting | `string` | `"corelight-cross-region-event-role"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cross_region_policy_arn"></a> [cross\_region\_policy\_arn](#output\_cross\_region\_policy\_arn) | n/a |
| <a name="output_cross_region_role_arn"></a> [cross\_region\_role\_arn](#output\_cross\_region\_role\_arn) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
