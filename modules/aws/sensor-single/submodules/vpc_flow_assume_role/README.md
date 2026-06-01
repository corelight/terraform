# VPC Flow Assume Role Module

Creates an IAM role that can be assumed by a trusted external AWS account for VPC Flow Log access.

## Usage

```hcl
module "vpc_flow_assume_role" {
  source = "./modules/vpc_flow_assume_role"

  trusted_account_id = "123456789012"
  trusted_role_name  = "corelight-flow-role"
  assume_role_name   = "corelight-cross-account-role"
}
```

The role grants the following EC2 permissions:
- `ec2:DescribeVpcs`
- `ec2:DescribeFlowLogs`

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
| <a name="input_assume_role_name"></a> [assume\_role\_name](#input\_assume\_role\_name) | The name of the role to create in this account | `string` | n/a | yes |
| <a name="input_trusted_account_id"></a> [trusted\_account\_id](#input\_trusted\_account\_id) | The AWS account ID that is allowed to assume this role | `string` | n/a | yes |
| <a name="input_trusted_role_name"></a> [trusted\_role\_name](#input\_trusted\_role\_name) | The name of the role in the trusted account that can assume this role | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_assume_role_arn"></a> [assume\_role\_arn](#output\_assume\_role\_arn) | ARN of the role that can be assumed |
| <a name="output_assume_role_name"></a> [assume\_role\_name](#output\_assume\_role\_name) | Name of the role that can be assumed |
| <a name="output_trusted_account_id"></a> [trusted\_account\_id](#output\_trusted\_account\_id) | The account ID that is trusted to assume this role |
<!-- END_TF_DOCS -->
