# IAM Role
An AWS IAM role needs to be created with the following assume role policy and permissions

# Assume Role Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

```

# Permissions

```json
{
    "Statement": [
        {
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Effect": "Allow",
            "Resource": "{ARN of the log group the ASG Lambda will use to create streams and write logs}:*"
        },
        {
            "Action": [
                "ec2:DescribeSubnets",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstances",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "autoscaling:CompleteLifecycleAction",
            "Effect": "Allow",
            "Resource": "{ARN of the sensor EC2 autoscaling group of Corelight sensors}"
        },
        {
            "Action": [
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:AttachNetworkInterface"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/aws:autoscaling:groupName": "{name of the Corelight sensor autoscaling group}"
                }
            },
            "Effect": "Allow",
            "Resource": "arn:aws:ec2:*:*:instance/*"
        },
        {
            "Action": [
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:DetachNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:AttachNetworkInterface"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/CorelightManaged": "true"
                }
            },
            "Effect": "Allow",
            "Resource": "arn:aws:ec2:*:*:network-interface/*"
        },
        {
            "Action": [
                "ec2:CreateTags",
                "ec2:CreateNetworkInterface"
            ],
            "Effect": "Allow",
            "Resource": [
                "{ARN of the subnet where new ENIs should be created. Typically your management subnet}",
                "{ARN of the security group that should be associated with newly created ENIs. Typically management sg}",
                "arn:aws:ec2:*:*:network-interface/*"
            ]
        }
    ],
    "Version": "2012-10-17"
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
| <a name="input_lambda_cloudwatch_log_group_arn"></a> [lambda\_cloudwatch\_log\_group\_arn](#input\_lambda\_cloudwatch\_log\_group\_arn) | ARN of the log group the Lambda will use to create streams and write logs | `string` | n/a | yes |
| <a name="input_security_group_arn"></a> [security\_group\_arn](#input\_security\_group\_arn) | ARN of the security group that should be associated with newly created ENIs | `string` | n/a | yes |
| <a name="input_sensor_autoscaling_group_arn"></a> [sensor\_autoscaling\_group\_arn](#input\_sensor\_autoscaling\_group\_arn) | ARN of the sensor EC2 autoscaling group of Corelight sensors | `string` | n/a | yes |
| <a name="input_subnet_arns"></a> [subnet\_arns](#input\_subnet\_arns) | ARNs of the subnets where new ENIs should be created (management), one per availability zone | `list(string)` | n/a | yes |
| <a name="input_lambda_policy_name"></a> [lambda\_policy\_name](#input\_lambda\_policy\_name) | Name of the policy granting permission to the ENI management lambda | `string` | `"corelight-asg-sensor-nic-manager-lambda-policy"` | no |
| <a name="input_lambda_role_name"></a> [lambda\_role\_name](#input\_lambda\_role\_name) | Name of the ENI management lambda role | `string` | `"corelight-asg-sensor-nic-manager-lambda-role"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | n/a |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | n/a |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | n/a |
<!-- END_TF_DOCS -->