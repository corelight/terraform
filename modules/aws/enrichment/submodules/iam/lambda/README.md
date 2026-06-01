# Enrichment Lambda IAM

IAM role and policy granting the cloud enrichment Lambda permission to enumerate cloud resources and write results to the enrichment bucket.

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
| <a name="input_enrichment_bucket_arn"></a> [enrichment\_bucket\_arn](#input\_enrichment\_bucket\_arn) | ARN of the s3 bucket cloud enrichment will use to store cloud resource data | `string` | n/a | yes |
| <a name="input_enrichment_ecr_repository_arn"></a> [enrichment\_ecr\_repository\_arn](#input\_enrichment\_ecr\_repository\_arn) | ARN of the ECR repository used to store the AWS enrichment docker image | `string` | n/a | yes |
| <a name="input_lambda_cloudwatch_log_group_arn"></a> [lambda\_cloudwatch\_log\_group\_arn](#input\_lambda\_cloudwatch\_log\_group\_arn) | ARN of the log group the Lambda will use to create streams and write logs | `string` | n/a | yes |
| <a name="input_lambda_iam_policy_name"></a> [lambda\_iam\_policy\_name](#input\_lambda\_iam\_policy\_name) | Name of the Lambda IAM policy | `string` | `"corelight-cloud-enrichment-lambda-policy"` | no |
| <a name="input_lambda_iam_role_name"></a> [lambda\_iam\_role\_name](#input\_lambda\_iam\_role\_name) | Name of the IAM role used to grant the cloud enrichment lambda permission to enumerate cloud resources and write results to the bucket | `string` | `"corelight-cloud-enrichment-lambda-role"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#output\_lambda\_iam\_role\_arn) | n/a |
| <a name="output_lambda_policy_arn"></a> [lambda\_policy\_arn](#output\_lambda\_policy\_arn) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
