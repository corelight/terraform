data "aws_subnet" "management" {
  for_each = toset(var.management_subnet_ids)
  id       = each.value
}

module "asg_lambda_role" {
  source = "../../../modules/aws/sensor/submodules/iam-lambda"

  lambda_cloudwatch_log_group_arn = module.sensor.cloudwatch_log_group_arn
  security_group_arn              = module.sensor.management_security_group_arn
  sensor_autoscaling_group_arn    = module.sensor.autoscaling_group_arn
  subnet_arns                     = [for s in data.aws_subnet.management : s.arn]

}

module "sensor" {
  source = "../../../modules/aws/sensor"

  aws_key_pair_name                 = var.sensor_ssh_key_pair_name
  corelight_sensor_ami_id           = var.sensor_ami_id
  license_key_file_path             = var.license_key_file_path
  management_subnet_ids             = var.management_subnet_ids
  monitoring_subnet_ids             = var.monitoring_subnet_ids
  community_string                  = var.community_string
  vpc_id                            = var.vpc_id
  asg_lambda_iam_role_arn           = module.asg_lambda_role.role_arn
  fleet_token                       = var.fleet_token
  fleet_url                         = var.fleet_url
  fleet_server_sslname              = var.fleet_server_sslname
  sensor_asg_name                   = var.sensor_asg_name != null ? var.sensor_asg_name : "${var.deployment_name}-asg"
  sensor_instance_name              = var.sensor_instance_name != null ? var.sensor_instance_name : "${var.deployment_name}-sensor"
  sensor_launch_template_name       = var.sensor_launch_template_name != null ? var.sensor_launch_template_name : "${var.deployment_name}-launch-template"
  sensor_asg_load_balancer_name     = var.sensor_asg_load_balancer_name != null ? var.sensor_asg_load_balancer_name : "${var.deployment_name}-lb"
  lb_health_check_target_group_name = var.lb_health_check_target_group_name != null ? var.lb_health_check_target_group_name : "${var.deployment_name}-gwlb-tg"

}
