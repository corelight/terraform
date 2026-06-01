# AWS Enrichment

Cloud enrichment service on AWS (Lambda + EventBridge).

## Usage

```hcl
module "enrichment" {
  source = "github.com/corelight/terraform//modules/aws/enrichment?ref=v28.4.0-1"

  enrichment_bucket_name   = "corelight-enrichment-metadata"
  enrichment_bucket_region = "us-east-1"

  corelight_cloud_enrichment_image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/corelight-enrichment"
  corelight_cloud_enrichment_image_tag = "latest"

  lambda_iam_role_arn                  = module.iam.lambda_role_arn
  eventbridge_iam_cross_region_role_arn = module.iam.eventbridge_role_arn
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_corelight_cloud_enrichment_image"></a> [corelight\_cloud\_enrichment\_image](#input\_corelight\_cloud\_enrichment\_image) | The ECR image copy of https://hub.docker.com/r/corelight/sensor-enrichment-aws | `string` | n/a | yes |
| <a name="input_corelight_cloud_enrichment_image_tag"></a> [corelight\_cloud\_enrichment\_image\_tag](#input\_corelight\_cloud\_enrichment\_image\_tag) | The tag of the ECR image | `string` | n/a | yes |
| <a name="input_enrichment_bucket_name"></a> [enrichment\_bucket\_name](#input\_enrichment\_bucket\_name) | The name of the enrichment bucket | `string` | n/a | yes |
| <a name="input_enrichment_bucket_region"></a> [enrichment\_bucket\_region](#input\_enrichment\_bucket\_region) | The AWS region where the enrichment bucket is located | `string` | n/a | yes |
| <a name="input_eventbridge_iam_cross_region_role_arn"></a> [eventbridge\_iam\_cross\_region\_role\_arn](#input\_eventbridge\_iam\_cross\_region\_role\_arn) | ARN of the IAM role deploy with the `modules/iam/eventbridge` sub-module | `string` | n/a | yes |
| <a name="input_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#input\_lambda\_iam\_role\_arn) | ARN of the IAM role deployed with the `modules/iam/lambda` sub-module | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_prefix"></a> [cloudwatch\_log\_group\_prefix](#input\_cloudwatch\_log\_group\_prefix) | The cloudwatch string prepended to the cloud watch log group name | `string` | `"/aws/lambda"` | no |
| <a name="input_cloudwatch_log_group_retention"></a> [cloudwatch\_log\_group\_retention](#input\_cloudwatch\_log\_group\_retention) | The Lambda log group retention in days | `number` | `3` | no |
| <a name="input_ec2_state_change_rule_name"></a> [ec2\_state\_change\_rule\_name](#input\_ec2\_state\_change\_rule\_name) | Name of the Event Bridge EC2 state change rule | `string` | `"corelight-ec2-state-change-rule"` | no |
| <a name="input_lambda_architecture"></a> [lambda\_architecture](#input\_lambda\_architecture) | Architecture used for the lambda. arm64 is recommended | `list(string)` | <pre>[<br/>  "arm64"<br/>]</pre> | no |
| <a name="input_lambda_env_bucket_prefix"></a> [lambda\_env\_bucket\_prefix](#input\_lambda\_env\_bucket\_prefix) | Lambda ENV: The prefix used on all cloud resource metadata object keys. Cannot contain a forward slash. | `string` | `"corelight"` | no |
| <a name="input_lambda_env_log_level"></a> [lambda\_env\_log\_level](#input\_lambda\_env\_log\_level) | Lambda ENV: The log level of the Corelight lambda | `string` | `"info"` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name of the Corelight Lambda used to collect and maintain the bucket | `string` | `"corelight-aws-cloud-enrichment"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The max duration the Lambda should be allowed to run. This may need to be adjusted for larger implementations | `number` | `60` | no |
| <a name="input_primary_event_bus_name"></a> [primary\_event\_bus\_name](#input\_primary\_event\_bus\_name) | The name of the event bus used to notify the Lambda of state changes | `string` | `"corelight-primary-event-bus"` | no |
| <a name="input_scheduled_sync_regions"></a> [scheduled\_sync\_regions](#input\_scheduled\_sync\_regions) | Lambda ENV: The regions the scheduled workflow should scan for running compute instances | `list(string)` | <pre>[<br/>  "us-east-1",<br/>  "us-east-2",<br/>  "us-west-1",<br/>  "us-west-2",<br/>  "ap-south-1",<br/>  "ap-northeast-1",<br/>  "ap-northeast-2",<br/>  "ap-northeast-3",<br/>  "ap-southeast-1",<br/>  "ap-southeast-2",<br/>  "ca-central-1",<br/>  "eu-central-1",<br/>  "eu-west-1",<br/>  "eu-west-2",<br/>  "eu-west-3",<br/>  "eu-north-1",<br/>  "sa-east-1"<br/>]</pre> | no |
| <a name="input_scheduled_sync_rule_frequency"></a> [scheduled\_sync\_rule\_frequency](#input\_scheduled\_sync\_rule\_frequency) | The frequency in which the Event Bridge cron should initiate a scheduled workflow in minutes | `number` | `15` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | n/a |
| <a name="output_default_bus_ec2_state_change_rule_arn"></a> [default\_bus\_ec2\_state\_change\_rule\_arn](#output\_default\_bus\_ec2\_state\_change\_rule\_arn) | n/a |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_primary_ec2_state_change_rule_arn"></a> [primary\_ec2\_state\_change\_rule\_arn](#output\_primary\_ec2\_state\_change\_rule\_arn) | n/a |
| <a name="output_primary_event_bus_arn"></a> [primary\_event\_bus\_arn](#output\_primary\_event\_bus\_arn) | n/a |
| <a name="output_scheduled_sync_rule_arn"></a> [scheduled\_sync\_rule\_arn](#output\_scheduled\_sync\_rule\_arn) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
