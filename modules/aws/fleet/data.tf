data "aws_route53_zone" "selected" {
  name = var.route53_zone_name
}

data "aws_ami" "ubuntu_ami" {
  count = var.fleet_ami_id == null ? 1 : 0

  owners      = ["099720109477"] # Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
