module "sensor" {
  source = "../../../modules/aws/sensor-single"

  deployment_name           = var.deployment_name
  ami_id                    = var.ami_id
  community_string          = var.community_string
  aws_key_pair_name         = var.aws_key_pair_name
  license_key_file_path     = var.license_key_file_path
  iam_instance_profile_name = aws_iam_instance_profile.flow_sensor.name

  monitoring_interface_subnet_id   = var.monitoring_interface_subnet_id
  monitoring_security_group_vpc_id = var.monitoring_security_group_vpc_id

  management_interface_subnet_id   = var.management_interface_subnet_id
  management_interface_public_ip   = var.management_interface_public_ip
  management_security_group_vpc_id = var.management_security_group_vpc_id

  ssh_allow_cidrs = var.ssh_allow_cidrs

  fleet_token          = var.fleet_token
  fleet_url            = var.fleet_url
  fleet_server_sslname = var.fleet_server_sslname
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      var.vpc_flow_logs_bucket_arn,
      "${var.vpc_flow_logs_bucket_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeFlowLogs",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.cross_account_role_name != "" ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::*:role/${var.cross_account_role_name}"]
    }
  }
}

resource "aws_iam_role" "flow_sensor" {
  name               = "${var.deployment_name}-flow-sensor-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_policy" "flow_sensor" {
  name   = "${var.deployment_name}-flow-sensor-policy"
  policy = data.aws_iam_policy_document.flow_policy.json
}

resource "aws_iam_role_policy_attachment" "flow_sensor" {
  role       = aws_iam_role.flow_sensor.name
  policy_arn = aws_iam_policy.flow_sensor.arn
}

resource "aws_iam_instance_profile" "flow_sensor" {
  name = "${var.deployment_name}-flow-sensor-profile"
  role = aws_iam_role.flow_sensor.name
}
