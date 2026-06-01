locals {
  # Computed Values
  fleet_server_ssl_name = "${var.subdomain}.${var.route53_zone_name}"
  fleet_base_url        = "https://${local.fleet_server_ssl_name}"
  fleet_url             = "${local.fleet_base_url}/fleet/v1"
  fleet_api_url         = "${local.fleet_base_url}:1443/fleet/v1/internal/softsensor/websocket"
  fleet_token           = data.external.fleet_token.result.token
}

module "corelight_fleet" {
  source = "../../../modules/aws/fleet"

  # Networking
  vpc_id            = var.fleet_vpc_id
  public_subnets    = var.public_subnets
  private_subnet    = var.private_subnet
  route53_zone_name = var.route53_zone_name
  subdomain         = var.subdomain
  certificate_arn   = var.certificate_arn

  # Optional networking
  alb_security_group_id         = var.alb_security_group_id
  instance_security_group_id    = var.instance_security_group_id
  alb_https_ingress_cidr_blocks = var.alb_https_ingress_cidr_blocks
  alb_api_ingress_cidr_blocks   = var.alb_api_ingress_cidr_blocks
  admin_cidr_blocks             = var.admin_cidr_blocks

  # EC2 Deployment
  aws_key_pair_name = var.aws_key_pair_name
  fleet_ami_id      = var.fleet_ami_id
  aws_ec2_size      = var.aws_ec2_size
  aws_volume_size   = var.aws_volume_size

  # Fleet Configuration
  fleet_version                  = var.fleet_version
  community_string               = var.community_string
  fleet_username                 = var.fleet_username
  fleet_password                 = var.fleet_password
  fleet_certificate_file_path    = var.fleet_certificate_file_path
  fleet_sensor_license_file_path = var.fleet_sensor_license_file_path

  # RADIUS Configuration
  radius_enable        = var.radius_enable
  radius_address       = var.radius_address
  radius_shared_secret = var.radius_shared_secret

  # Naming
  fleet_instance_name                = var.fleet_instance_name
  fleet_alb_name                     = var.fleet_alb_name
  fleet_lb_target_group_name         = var.fleet_lb_target_group_name
  fleet_alb_security_group_name      = var.fleet_alb_security_group_name
  fleet_instance_security_group_name = var.fleet_instance_security_group_name
}

resource "null_resource" "fleet_delay" {
  depends_on = [module.corelight_fleet]

  provisioner "local-exec" {
    command = <<EOT
until curl -k -s -o /dev/null -w "%%{http_code}" "${local.fleet_base_url}" | grep -q "200"; do
  echo "Waiting for Fleet to be ready at ${local.fleet_base_url}..."
  sleep 5
done
EOT
  }
}

module "corelight_single_sensor" {
  source = "../../../modules/aws/sensor-single"

  depends_on = [null_resource.fleet_delay]

  # Core configuration
  ami_id                         = var.corelight_sensor_ami_id
  management_interface_subnet_id = var.management_subnet_id
  monitoring_interface_subnet_id = var.monitoring_subnet_id
  aws_key_pair_name              = var.aws_key_pair_name

  # Instance configuration
  management_security_group_vpc_id = var.sensor_vpc_id
  monitoring_security_group_vpc_id = var.sensor_vpc_id
  management_interface_public_ip   = var.associate_public_ip_address
  custom_sensor_user_data          = var.custom_sensor_user_data
  instance_name                    = var.sensor_instance_name
  instance_type                    = var.instance_type
  ebs_volume_size                  = var.ebs_volume_size

  # Network interfaces
  management_interface_name = var.management_interface_name
  monitoring_interface_name = var.monitoring_interface_name

  # Security groups
  management_security_group_name        = var.sensor_management_security_group_name
  management_security_group_description = var.sensor_management_security_group_description
  monitoring_security_group_name        = var.sensor_monitoring_security_group_name
  monitoring_security_group_description = var.sensor_monitoring_security_group_description
  ssh_allow_cidrs                       = var.admin_cidr_blocks

  # Licensing and Fleet
  community_string     = var.community_string
  fleet_token          = local.fleet_token
  fleet_url            = local.fleet_api_url
  fleet_server_sslname = local.fleet_server_ssl_name
}
