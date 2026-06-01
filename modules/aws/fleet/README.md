# AWS Fleet

Corelight Fleet Manager on AWS (ALB + EC2 + Route53).

## Usage

```hcl
module "fleet" {
  source = "github.com/corelight/terraform//modules/aws/fleet?ref=v28.4.0-1"

  vpc_id            = "vpc-12345abc"
  public_subnets    = ["subnet-aaa", "subnet-bbb"]
  private_subnet    = "subnet-ccc"
  route53_zone_name = "example.com"
  aws_key_pair_name = "your-key-pair"

  community_string = "your-community-string"
  fleet_username   = "admin"
  fleet_password   = "your-fleet-password"

  fleet_certificate_file_path    = "/path/to/cert.pem"
  fleet_sensor_license_file_path = "/path/to/license.txt"
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
| <a name="input_aws_key_pair_name"></a> [aws\_key\_pair\_name](#input\_aws\_key\_pair\_name) | The name of the AWS key pair for accessing Fleet instances. | `string` | n/a | yes |
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | Fleet community string for sensor pairing. | `string` | n/a | yes |
| <a name="input_fleet_certificate_file_path"></a> [fleet\_certificate\_file\_path](#input\_fleet\_certificate\_file\_path) | Path to the Fleet certificate file. | `string` | n/a | yes |
| <a name="input_fleet_password"></a> [fleet\_password](#input\_fleet\_password) | Fleet admin password. | `string` | n/a | yes |
| <a name="input_fleet_sensor_license_file_path"></a> [fleet\_sensor\_license\_file\_path](#input\_fleet\_sensor\_license\_file\_path) | Path to the Fleet sensor license file. | `string` | n/a | yes |
| <a name="input_fleet_username"></a> [fleet\_username](#input\_fleet\_username) | Fleet admin username. | `string` | n/a | yes |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | The ID of the subnet where Fleet instance will be deployed. | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of subnet IDs where the ALB will be deployed. | `list(string)` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | The Route53 hosted zone name (e.g., example.com.). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where resources will be deployed. | `string` | n/a | yes |
| <a name="input_admin_cidr_blocks"></a> [admin\_cidr\_blocks](#input\_admin\_cidr\_blocks) | List of CIDR blocks for admin access to Fleet instance (e.g., your home or office IP). | `list(string)` | `[]` | no |
| <a name="input_alb_api_ingress_cidr_blocks"></a> [alb\_api\_ingress\_cidr\_blocks](#input\_alb\_api\_ingress\_cidr\_blocks) | List of CIDR blocks allowed to access Fleet API on port 1443 | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_alb_https_ingress_cidr_blocks"></a> [alb\_https\_ingress\_cidr\_blocks](#input\_alb\_https\_ingress\_cidr\_blocks) | List of CIDR blocks allowed to access ALB on HTTPS (443) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | Optional: Existing ALB security group ID to use | `string` | `null` | no |
| <a name="input_aws_ec2_size"></a> [aws\_ec2\_size](#input\_aws\_ec2\_size) | EC2 instance type/size. Follow documentation for Fleet to determine the appropriate size. | `string` | `"t3.large"` | no |
| <a name="input_aws_volume_size"></a> [aws\_volume\_size](#input\_aws\_volume\_size) | Root EBS volume size (GB). | `number` | `50` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN for HTTPS. Optional; if not provided, users will see a browser warning when accessing Fleet. | `string` | `""` | no |
| <a name="input_fleet_alb_name"></a> [fleet\_alb\_name](#input\_fleet\_alb\_name) | The name of the Fleet ALB. | `string` | `"corelight-fleet-alb"` | no |
| <a name="input_fleet_alb_security_group_name"></a> [fleet\_alb\_security\_group\_name](#input\_fleet\_alb\_security\_group\_name) | Name of the security group used by the ALB. | `string` | `"corelight-fleet-alb-security-group"` | no |
| <a name="input_fleet_ami_id"></a> [fleet\_ami\_id](#input\_fleet\_ami\_id) | Optional: AMI ID to use for Fleet instance. If not provided, the latest Ubuntu 22.04 LTS AMI will be used. | `string` | `null` | no |
| <a name="input_fleet_instance_name"></a> [fleet\_instance\_name](#input\_fleet\_instance\_name) | The Fleet instance name. | `string` | `"corelight-fleet"` | no |
| <a name="input_fleet_instance_security_group_name"></a> [fleet\_instance\_security\_group\_name](#input\_fleet\_instance\_security\_group\_name) | Name of the security group used by the Fleet instance. | `string` | `"corelight-fleet-instance-security-group"` | no |
| <a name="input_fleet_lb_target_group_name"></a> [fleet\_lb\_target\_group\_name](#input\_fleet\_lb\_target\_group\_name) | The name of the Fleet ALB target group. | `string` | `"corelight-fleet-tg"` | no |
| <a name="input_fleet_version"></a> [fleet\_version](#input\_fleet\_version) | The version of Fleet to deploy. | `string` | `"28.2.2"` | no |
| <a name="input_instance_security_group_id"></a> [instance\_security\_group\_id](#input\_instance\_security\_group\_id) | Optional: Existing instance security group ID to use | `string` | `null` | no |
| <a name="input_radius_address"></a> [radius\_address](#input\_radius\_address) | RADIUS server address and port (e.g., 1.2.3.4:1812). If RADIUS is enabled, this must be set. | `string` | `""` | no |
| <a name="input_radius_enable"></a> [radius\_enable](#input\_radius\_enable) | Enable RADIUS authentication. Optional; if not set, RADIUS will not be configured. | `bool` | `false` | no |
| <a name="input_radius_shared_secret"></a> [radius\_shared\_secret](#input\_radius\_shared\_secret) | RADIUS shared secret. If RADIUS is enabled, this must be set. | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain for Fleet to be prefixed to the hosted zone name (e.g., fleet). | `string` | `"fleet"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
