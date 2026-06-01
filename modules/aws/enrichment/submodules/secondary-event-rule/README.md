# secondary-event-rule

Documentation coming soon.

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
| <a name="input_cross_region_eventbridge_role_arn"></a> [cross\_region\_eventbridge\_role\_arn](#input\_cross\_region\_eventbridge\_role\_arn) | ARN of the eventbridge IAM role granting permission to put events on the Corelight primary Event Bus | `string` | n/a | yes |
| <a name="input_primary_event_bus_arn"></a> [primary\_event\_bus\_arn](#input\_primary\_event\_bus\_arn) | ARN of the primary Corelight event bus which all events should fan in to | `string` | n/a | yes |
| <a name="input_secondary_ec2_state_change_rule_name"></a> [secondary\_ec2\_state\_change\_rule\_name](#input\_secondary\_ec2\_state\_change\_rule\_name) | Name of the secondary EC2 state change rule | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_event_bridge_rule_arn"></a> [event\_bridge\_rule\_arn](#output\_event\_bridge\_rule\_arn) | n/a |
<!-- END_TF_DOCS -->