# Sensor Enrichment IAM

IAM role and policy granting the Corelight sensor permission to read enrichment data from the enrichment bucket.

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
| <a name="input_enrichment_bucket_arn"></a> [enrichment\_bucket\_arn](#input\_enrichment\_bucket\_arn) | ARN of the enrichment bucket the sensor will need to read from | `string` | n/a | yes |
| <a name="input_corelight_sensor_policy_name"></a> [corelight\_sensor\_policy\_name](#input\_corelight\_sensor\_policy\_name) | Name of the policy used by the Corelight sensor | `string` | `"corelight-sensor-cloud-enrichment-policy"` | no |
| <a name="input_corelight_sensor_role_name"></a> [corelight\_sensor\_role\_name](#input\_corelight\_sensor\_role\_name) | Name of the role created to read the | `string` | `"corelight-sensor-cloud-enrichment-role"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_sensor_policy_arn"></a> [sensor\_policy\_arn](#output\_sensor\_policy\_arn) | n/a |
| <a name="output_sensor_role_arn"></a> [sensor\_role\_arn](#output\_sensor\_role\_arn) | n/a |
| <a name="output_sensor_role_name"></a> [sensor\_role\_name](#output\_sensor\_role\_name) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
