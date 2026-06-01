module "fleet" {
  source = "../../../modules/aws/fleet"

  vpc_id                         = var.vpc_id
  public_subnets                 = var.public_subnets
  private_subnet                 = var.private_subnet
  route53_zone_name              = var.route53_zone_name
  subdomain                      = var.subdomain
  certificate_arn                = var.certificate_arn
  aws_key_pair_name              = var.aws_key_pair_name
  community_string               = var.community_string
  fleet_username                 = var.fleet_username
  fleet_password                 = var.fleet_password
  fleet_certificate_file_path    = var.fleet_certificate_file_path
  fleet_sensor_license_file_path = var.fleet_sensor_license_file_path
}
