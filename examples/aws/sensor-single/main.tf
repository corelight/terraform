module "sensor" {
  source = "../../../modules/aws/sensor-single"

  deployment_name       = var.deployment_name
  ami_id                = var.ami_id
  community_string      = var.community_string
  aws_key_pair_name     = var.aws_key_pair_name
  license_key_file_path = var.license_key_file_path

  monitoring_interface_subnet_id   = var.monitoring_interface_subnet_id
  monitoring_security_group_vpc_id = var.monitoring_security_group_vpc_id

  management_interface_subnet_id   = var.management_interface_subnet_id
  management_interface_public_ip   = var.management_interface_public_ip
  management_security_group_vpc_id = var.management_security_group_vpc_id

  ssh_allow_cidrs = var.ssh_allow_cidrs
}
