# AWS Sensor Single

Single-instance Corelight sensor on AWS EC2.

## Usage

```hcl
module "sensor" {
  source = "github.com/corelight/terraform//modules/aws/sensor-single?ref=v28.4.0-1"

  ami_id            = "ami-12345abc"
  aws_key_pair_name = "your-key-pair"
  community_string  = "your-community-string"

  monitoring_interface_subnet_id   = "subnet-123abc"
  monitoring_security_group_vpc_id = "vpc-456def"

  management_interface_subnet_id   = "subnet-789ghi"
  management_security_group_vpc_id = "vpc-456def"

  license_key_file_path = "/path/to/license.txt"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) |  >= 5 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) |  >= 5 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI ID provided by Corelight | `string` | n/a | yes |
| <a name="input_aws_key_pair_name"></a> [aws\_key\_pair\_name](#input\_aws\_key\_pair\_name) | The name of the AWS key pair that will be used to access the sensor instances in the auto-scale group | `string` | n/a | yes |
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | The community string (api password) for sensor management | `string` | n/a | yes |
| <a name="input_custom_sensor_user_data"></a> [custom\_sensor\_user\_data](#input\_custom\_sensor\_user\_data) | Custom user data for a sensor if the default doesn't apply | `string` | `""` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name prefix for all resources (used to avoid naming conflicts) | `string` | `"corelight-sensor"` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | The size, in GB, of the EBS volume to be attached to the instance. Not recommended to set lower than 500GB | `number` | `500` | no |
| <a name="input_egress_allow_cidrs"></a> [egress\_allow\_cidrs](#input\_egress\_allow\_cidrs) | The IP range allowed outbound for both network interfaces. Typically can be left as default | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | (optional) the SSL hostname for the fleet server | `string` | `"1.broala.fleet.product.corelight.io"` | no |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | (optional) the pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | `""` | no |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | (optional) the URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | `""` | no |
| <a name="input_health_check_allow_cidrs"></a> [health\_check\_allow\_cidrs](#input\_health\_check\_allow\_cidrs) | IP range to allow health checks. Typically the CIDR of the VPC being monitored | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of the IAM instance profile that should be attached to the EC2 instance | `string` | `""` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name for the sensor EC2 instance (defaults to <deployment\_name>-sensor) | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the EC2 instance | `string` | `"c5.2xlarge"` | no |
| <a name="input_license_key_file_path"></a> [license\_key\_file\_path](#input\_license\_key\_file\_path) | The path to your Corelight sensor license key. This must be provided if not licensing through fleet | `string` | `""` | no |
| <a name="input_management_interface_id"></a> [management\_interface\_id](#input\_management\_interface\_id) | Used in place of the 'management\_interface' variable if you would like to provide one | `string` | `""` | no |
| <a name="input_management_interface_name"></a> [management\_interface\_name](#input\_management\_interface\_name) | The name of the management interface for the sensor (defaults to <deployment\_name>-mgmt-nic) | `string` | `null` | no |
| <a name="input_management_interface_public_ip"></a> [management\_interface\_public\_ip](#input\_management\_interface\_public\_ip) | The flag to determine if the management interface for the sensor should have a publicly assigned IP address | `bool` | `false` | no |
| <a name="input_management_interface_subnet_id"></a> [management\_interface\_subnet\_id](#input\_management\_interface\_subnet\_id) | The subnet id of the management interface for the sensor | `string` | `""` | no |
| <a name="input_management_security_group_description"></a> [management\_security\_group\_description](#input\_management\_security\_group\_description) | Description of the management ENI security group | `string` | `"Corelight Sensor Managment SG"` | no |
| <a name="input_management_security_group_id"></a> [management\_security\_group\_id](#input\_management\_security\_group\_id) | Used in place of the 'management\_security\_group' variable if you would like to provide one | `string` | `""` | no |
| <a name="input_management_security_group_name"></a> [management\_security\_group\_name](#input\_management\_security\_group\_name) | Name of the security group the module will provision for the management ENI (defaults to <deployment\_name>-mgmt-sg) | `string` | `null` | no |
| <a name="input_management_security_group_vpc_id"></a> [management\_security\_group\_vpc\_id](#input\_management\_security\_group\_vpc\_id) | Security group VPC ID module will use to provision the management ENI security group | `string` | `""` | no |
| <a name="input_mirror_ingress_allow_cidrs"></a> [mirror\_ingress\_allow\_cidrs](#input\_mirror\_ingress\_allow\_cidrs) | IP range to allow EC2 mirroring. Typically the CIDR of the VPC being monitored | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_monitoring_interface_id"></a> [monitoring\_interface\_id](#input\_monitoring\_interface\_id) | The ID of a pre-exiting ENI if you would rather create it outside of the module | `string` | `""` | no |
| <a name="input_monitoring_interface_name"></a> [monitoring\_interface\_name](#input\_monitoring\_interface\_name) | The name of the monitoring interface for the sensor (defaults to <deployment\_name>-mon-nic) | `string` | `null` | no |
| <a name="input_monitoring_interface_subnet_id"></a> [monitoring\_interface\_subnet\_id](#input\_monitoring\_interface\_subnet\_id) | Subnet where the monitoring ENI should reside | `string` | `""` | no |
| <a name="input_monitoring_security_group_description"></a> [monitoring\_security\_group\_description](#input\_monitoring\_security\_group\_description) | Description of the monitoring ENI security group | `string` | `"Corelight Sensor Monitoring SG"` | no |
| <a name="input_monitoring_security_group_id"></a> [monitoring\_security\_group\_id](#input\_monitoring\_security\_group\_id) | Used in place of the 'monitoring\_security\_group' variable if you would like to provide one | `string` | `""` | no |
| <a name="input_monitoring_security_group_name"></a> [monitoring\_security\_group\_name](#input\_monitoring\_security\_group\_name) | Name of the security group the module will provision for the monitoring ENI (defaults to <deployment\_name>-mon-sg) | `string` | `null` | no |
| <a name="input_monitoring_security_group_vpc_id"></a> [monitoring\_security\_group\_vpc\_id](#input\_monitoring\_security\_group\_vpc\_id) | Security group VPC ID module will use to provision the monitoring ENI security group | `string` | `""` | no |
| <a name="input_ssh_allow_cidrs"></a> [ssh\_allow\_cidrs](#input\_ssh\_allow\_cidrs) | List of IPs (/32) to grant access to port 22 | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_management_interface_id"></a> [management\_interface\_id](#output\_management\_interface\_id) | Network interface ID for management traffic |
| <a name="output_monitoring_interface_id"></a> [monitoring\_interface\_id](#output\_monitoring\_interface\_id) | Network interface ID for monitoring traffic |
| <a name="output_sensor_instance_id"></a> [sensor\_instance\_id](#output\_sensor\_instance\_id) | EC2 instance ID of the sensor |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
