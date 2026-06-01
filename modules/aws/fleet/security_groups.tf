resource "aws_security_group" "alb_security_group" {
  count  = var.alb_security_group_id == null ? 1 : 0
  name   = var.fleet_alb_security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = var.fleet_alb_security_group_name
  }
}

resource "aws_security_group" "instance_security_group" {
  count  = var.instance_security_group_id == null ? 1 : 0
  name   = var.fleet_instance_security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = var.fleet_instance_security_group_name
  }
}

# Use provided SGs or the ones we create
locals {
  alb_sg_id      = var.alb_security_group_id != null ? var.alb_security_group_id : aws_security_group.alb_security_group[0].id
  instance_sg_id = var.instance_security_group_id != null ? var.instance_security_group_id : aws_security_group.instance_security_group[0].id
  fleet_ami_id   = var.fleet_ami_id != null ? var.fleet_ami_id : data.aws_ami.ubuntu_ami[0].id
}

# ALB SG Rules
resource "aws_security_group_rule" "alb_https_ingress" {
  count             = var.alb_security_group_id == null ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.alb_https_ingress_cidr_blocks
  security_group_id = local.alb_sg_id
}

resource "aws_security_group_rule" "alb_api_ingress" {
  count             = var.alb_security_group_id == null ? 1 : 0
  type              = "ingress"
  from_port         = 1443
  to_port           = 1443
  protocol          = "tcp"
  cidr_blocks       = var.alb_api_ingress_cidr_blocks
  security_group_id = local.alb_sg_id
}

resource "aws_security_group_rule" "alb_https_egress" {
  count             = var.alb_security_group_id == null ? 1 : 0
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.alb_sg_id
}

resource "aws_security_group_rule" "alb_api_egress" {
  count             = var.alb_security_group_id == null ? 1 : 0
  type              = "egress"
  from_port         = 1443
  to_port           = 1443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.alb_sg_id
}

# Instance SG Rules
resource "aws_security_group_rule" "instance_all_egress" {
  count             = var.instance_security_group_id == null ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.instance_sg_id
}

resource "aws_security_group_rule" "instance_https_from_alb" {
  count                    = var.instance_security_group_id == null ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = local.alb_sg_id
  security_group_id        = local.instance_sg_id
}

resource "aws_security_group_rule" "instance_fleet_api_ingress" {
  count                    = var.instance_security_group_id == null ? 1 : 0
  type                     = "ingress"
  from_port                = 1443
  to_port                  = 1443
  protocol                 = "tcp"
  source_security_group_id = local.alb_sg_id
  security_group_id        = local.instance_sg_id
}

resource "aws_security_group_rule" "instance_admin_ingress" {
  count             = var.instance_security_group_id == null && length(var.admin_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.admin_cidr_blocks
  security_group_id = local.instance_sg_id
}