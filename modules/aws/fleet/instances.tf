resource "aws_instance" "fleet_instance" {
  ami                    = local.fleet_ami_id
  instance_type          = var.aws_ec2_size
  key_name               = var.aws_key_pair_name
  user_data              = module.fleet_config.cloudinit_config.rendered
  subnet_id              = var.private_subnet
  vpc_security_group_ids = [local.instance_sg_id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.aws_volume_size
    encrypted   = true
  }

  tags = {
    Name = var.fleet_instance_name
  }
}