# AWS Sensor

Auto-scaling Corelight sensor deployment on AWS with Gateway Load Balancer.

## Usage

```hcl
module "asg_lambda_role" {
  source = "github.com/corelight/terraform//modules/aws/sensor/submodules/iam-lambda?ref=v28.4.0-1"
}

module "sensor" {
  source = "github.com/corelight/terraform//modules/aws/sensor?ref=v28.4.0-1"

  vpc_id                  = "vpc-12345abc"
  monitoring_subnet_ids   = ["subnet-aaa", "subnet-bbb"]
  management_subnet_ids   = ["subnet-ccc", "subnet-ddd"]
  aws_key_pair_name       = "your-key-pair"
  corelight_sensor_ami_id = "ami-12345abc"
  community_string        = "your-community-string"

  fleet_token          = "your-fleet-token"
  fleet_url            = "https://fleet.example.com:1443/..."
  fleet_server_sslname = "fleet.example.com"

  asg_lambda_iam_role_arn = module.asg_lambda_role.role_arn
}
```

## Scaling behavior

The ASG starts at `sensor_asg_desired_capacity` (default 1) and scales between
`sensor_asg_min_size` (default 1) and `sensor_asg_max_size` (default 5) based
on average CPU across the group:

- **Scale out (+1 instance):** average `CPUUtilization > 70%` for 2 consecutive
  60s periods.
- **Scale in (-1 instance):** average `CPUUtilization < 30%` for 5 consecutive
  60s periods.

Termination policy is `OldestInstance`. CPU thresholds and evaluation periods
are not currently exposed as input variables.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_asg_lambda_iam_role_arn"></a> [asg\_lambda\_iam\_role\_arn](#input\_asg\_lambda\_iam\_role\_arn) | ARN of the ASG lambda role created in the `iam/lambda` sub-module | `string` | n/a | yes |
| <a name="input_aws_key_pair_name"></a> [aws\_key\_pair\_name](#input\_aws\_key\_pair\_name) | The name of the AWS key pair that will be used to access the sensor instances in the auto-scale group | `string` | n/a | yes |
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | The community string (api password) for sensor management | `string` | n/a | yes |
| <a name="input_corelight_sensor_ami_id"></a> [corelight\_sensor\_ami\_id](#input\_corelight\_sensor\_ami\_id) | The AMI ID of the Corelight sensor. Request access to the AMI from your account executive | `string` | n/a | yes |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | SSL hostname for the fleet server | `string` | n/a | yes |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | Pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | n/a | yes |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | n/a | yes |
| <a name="input_management_subnet_ids"></a> [management\_subnet\_ids](#input\_management\_subnet\_ids) | List of subnet IDs used to SSH / manage Corelight sensors, one per availability zone | `list(string)` | n/a | yes |
| <a name="input_monitoring_subnet_ids"></a> [monitoring\_subnet\_ids](#input\_monitoring\_subnet\_ids) | List of subnet IDs where monitor traffic will be available, one per availability zone | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where resources will be deployed | `string` | n/a | yes |
| <a name="input_asg_lifecycle_hook_name"></a> [asg\_lifecycle\_hook\_name](#input\_asg\_lifecycle\_hook\_name) | name of the lifecycle hook triggered when new instances are launched | `string` | `"scaling-up"` | no |
| <a name="input_cloudwatch_log_group_prefix"></a> [cloudwatch\_log\_group\_prefix](#input\_cloudwatch\_log\_group\_prefix) | The cloudwatch string prepended to the cloud watch log group name | `string` | `"/aws/lambda"` | no |
| <a name="input_cloudwatch_log_group_retention"></a> [cloudwatch\_log\_group\_retention](#input\_cloudwatch\_log\_group\_retention) | The Lambda log group retention in days | `number` | `3` | no |
| <a name="input_eventbridge_lifecycle_rule_name"></a> [eventbridge\_lifecycle\_rule\_name](#input\_eventbridge\_lifecycle\_rule\_name) | Auto Scale Group EventBridge rule name | `string` | `"corelight-asg-sensor-lifecycle-notification"` | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_instance_profile_arn"></a> [instance\_profile\_arn](#input\_instance\_profile\_arn) | (optional) Instance profile must be added granting cloud features access to AWS APIs | `string` | `""` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key ID to be used for EBS volume encryption for the auto-scale group instances | `string` | `null` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the ENI management lambda function | `string` | `"corelight-asg-sensor-nic-manager"` | no |
| <a name="input_lb_health_check_target_group_name"></a> [lb\_health\_check\_target\_group\_name](#input\_lb\_health\_check\_target\_group\_name) | The name of the health check target group which determines if the sensor in the ASG comes up and is ready to accept traffic | `string` | `"corelight-sensor-gwlb-tg"` | no |
| <a name="input_license_key_file_path"></a> [license\_key\_file\_path](#input\_license\_key\_file\_path) | Path to your Corelight sensor license key file. Optional if fleet\_url is configured. | `string` | `""` | no |
| <a name="input_sensor_asg_auto_scale_policy_name"></a> [sensor\_asg\_auto\_scale\_policy\_name](#input\_sensor\_asg\_auto\_scale\_policy\_name) | The name of the auto-scale group scale-out policy | `string` | `"corelight-sensor-asg-policy"` | no |
| <a name="input_sensor_asg_desired_capacity"></a> [sensor\_asg\_desired\_capacity](#input\_sensor\_asg\_desired\_capacity) | Initial desired number of sensor instances in the auto-scale group | `number` | `1` | no |
| <a name="input_sensor_asg_load_balancer_name"></a> [sensor\_asg\_load\_balancer\_name](#input\_sensor\_asg\_load\_balancer\_name) | The name of the load balancer which fronts the auto-scale group | `string` | `"corelight-sensor-lb"` | no |
| <a name="input_sensor_asg_max_size"></a> [sensor\_asg\_max\_size](#input\_sensor\_asg\_max\_size) | Maximum number of sensor instances in the auto-scale group | `number` | `5` | no |
| <a name="input_sensor_asg_min_size"></a> [sensor\_asg\_min\_size](#input\_sensor\_asg\_min\_size) | Minimum number of sensor instances in the auto-scale group | `number` | `1` | no |
| <a name="input_sensor_asg_name"></a> [sensor\_asg\_name](#input\_sensor\_asg\_name) | The name of the Corelight sensor auto-scale group | `string` | `"corelight-sensor-asg"` | no |
| <a name="input_sensor_asg_scale_in_policy_name"></a> [sensor\_asg\_scale\_in\_policy\_name](#input\_sensor\_asg\_scale\_in\_policy\_name) | The name of the auto-scale group scale-in policy | `string` | `"corelight-sensor-asg-scale-in-policy"` | no |
| <a name="input_sensor_health_check_http_port"></a> [sensor\_health\_check\_http\_port](#input\_sensor\_health\_check\_http\_port) | The port used for health checks on the sensor | `number` | `41080` | no |
| <a name="input_sensor_instance_name"></a> [sensor\_instance\_name](#input\_sensor\_instance\_name) | The name tag applied to EC2 instances launched by the auto-scale group | `string` | `"corelight-sensor"` | no |
| <a name="input_sensor_launch_template_instance_type"></a> [sensor\_launch\_template\_instance\_type](#input\_sensor\_launch\_template\_instance\_type) | The instance type the auto-scale group will use for each instance | `string` | `"c5.2xlarge"` | no |
| <a name="input_sensor_launch_template_name"></a> [sensor\_launch\_template\_name](#input\_sensor\_launch\_template\_name) | The name of the launch template used by the auto-scale group | `string` | `"corelight-sensor-launch-template"` | no |
| <a name="input_sensor_launch_template_volume_name"></a> [sensor\_launch\_template\_volume\_name](#input\_sensor\_launch\_template\_volume\_name) | The name of the volume for the sensor launch template | `string` | `"/dev/xvda"` | no |
| <a name="input_sensor_launch_template_volume_size"></a> [sensor\_launch\_template\_volume\_size](#input\_sensor\_launch\_template\_volume\_size) | The size of the volume for the sensor launch template | `number` | `500` | no |
| <a name="input_sensor_management_security_group_description"></a> [sensor\_management\_security\_group\_description](#input\_sensor\_management\_security\_group\_description) | Name of the security group used to allow SSH access to the sensor | `string` | `"Security group for the sensor which allows SSH access"` | no |
| <a name="input_sensor_management_security_group_name"></a> [sensor\_management\_security\_group\_name](#input\_sensor\_management\_security\_group\_name) | Name of the security group used to allow access to the monitoring NIC | `string` | `"corelight-sensor-management"` | no |
| <a name="input_sensor_monitoring_security_group_description"></a> [sensor\_monitoring\_security\_group\_description](#input\_sensor\_monitoring\_security\_group\_description) | Description of the security group used to allow access to the monitoring NIC | `string` | `"Security group for the sensor which allows health check and GENEVE traffic inbound"` | no |
| <a name="input_sensor_monitoring_security_group_name"></a> [sensor\_monitoring\_security\_group\_name](#input\_sensor\_monitoring\_security\_group\_name) | Name of the security group used to allow health check and GENEVE traffic to the sensor | `string` | `"corelight-sensor-monitoring"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_auto_scale_group_cloudwatch_alarm_id"></a> [auto\_scale\_group\_cloudwatch\_alarm\_id](#output\_auto\_scale\_group\_cloudwatch\_alarm\_id) | n/a |
| <a name="output_auto_scale_policy_id"></a> [auto\_scale\_policy\_id](#output\_auto\_scale\_policy\_id) | n/a |
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | n/a |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | n/a |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | n/a |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | n/a |
| <a name="output_load_balancer_health_check_target_group"></a> [load\_balancer\_health\_check\_target\_group](#output\_load\_balancer\_health\_check\_target\_group) | n/a |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | n/a |
| <a name="output_load_balancer_listener_id"></a> [load\_balancer\_listener\_id](#output\_load\_balancer\_listener\_id) | n/a |
| <a name="output_management_security_group_arn"></a> [management\_security\_group\_arn](#output\_management\_security\_group\_arn) | n/a |
| <a name="output_management_security_group_id"></a> [management\_security\_group\_id](#output\_management\_security\_group\_id) | n/a |
| <a name="output_monitoring_security_group_arn"></a> [monitoring\_security\_group\_arn](#output\_monitoring\_security\_group\_arn) | n/a |
| <a name="output_monitoring_security_group_id"></a> [monitoring\_security\_group\_id](#output\_monitoring\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
