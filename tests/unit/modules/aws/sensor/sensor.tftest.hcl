# Unit tests for AWS Sensor Module
# These tests validate the module configuration without deploying real infrastructure

mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      arn               = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-mock"
      availability_zone = "us-east-1a"
      vpc_id            = "vpc-test123456"
      cidr_block        = "10.0.1.0/24"
      id                = "subnet-mock"
    }
  }

  mock_data "aws_vpc" {
    defaults = {
      id         = "vpc-test123456"
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
    }
  }
}

mock_provider "archive" {
  mock_data "archive_file" {
    defaults = {
      output_path         = "mock_lambda.zip"
      output_base64sha256 = "mock_hash"
      output_size         = 1024
    }
  }
}
mock_provider "cloudinit" {}

run "verify_required_variables" {
  command = plan

  module {
    source = "./modules/aws/sensor"
  }

  variables {
    vpc_id                  = "vpc-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    corelight_sensor_ami_id = "ami-test123456"
    aws_key_pair_name       = "test-keypair"
    license_key             = "test-license-key"
    community_string        = "test-community-string"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.name == "corelight-sensor-asg"
    error_message = "ASG name should default to 'corelight-sensor-asg'"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.name == "corelight-sensor-launch-template"
    error_message = "Launch template name should default to 'corelight-sensor-launch-template'"
  }

  assert {
    condition     = aws_lb.sensor_lb.name == "corelight-sensor-lb"
    error_message = "Load balancer name should default to 'corelight-sensor-lb'"
  }
}

run "verify_custom_names" {
  command = plan

  module {
    source = "./modules/aws/sensor"
  }

  variables {
    vpc_id                            = "vpc-test123456"
    monitoring_subnet_ids             = ["subnet-mon123456"]
    management_subnet_ids             = ["subnet-mgmt123456"]
    corelight_sensor_ami_id           = "ami-test123456"
    aws_key_pair_name                 = "test-keypair"
    license_key                       = "test-license-key"
    community_string                  = "test-community-string"
    asg_lambda_iam_role_arn           = "arn:aws:iam::123456789012:role/test-role"
    fleet_token                       = "test-token"
    fleet_url                         = "https://fleet.example.com"
    fleet_server_sslname              = "fleet.example.com"
    sensor_asg_name                   = "custom-asg"
    sensor_instance_name              = "custom-sensor"
    sensor_launch_template_name       = "custom-template"
    sensor_asg_load_balancer_name     = "custom-lb"
    lb_health_check_target_group_name = "custom-tg"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.name == "custom-asg"
    error_message = "ASG name should be customizable"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.name == "custom-template"
    error_message = "Launch template name should be customizable"
  }

  assert {
    condition     = aws_lb.sensor_lb.name == "custom-lb"
    error_message = "Load balancer name should be customizable"
  }

  assert {
    condition     = aws_lb_target_group.health_check.name == "custom-tg"
    error_message = "Target group name should be customizable"
  }
}

run "verify_asg_configuration" {
  command = plan

  module {
    source = "./modules/aws/sensor"
  }

  variables {
    vpc_id                  = "vpc-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    corelight_sensor_ami_id = "ami-test123456"
    aws_key_pair_name       = "test-keypair"
    license_key             = "test-license-key"
    community_string        = "test-community-string"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.min_size == 1
    error_message = "ASG minimum size should be 1"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.max_size == 5
    error_message = "ASG maximum size should be 5"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.desired_capacity == 1
    error_message = "ASG desired capacity should be 1"
  }

  assert {
    condition     = aws_autoscaling_group.sensor_asg.health_check_type == "EC2"
    error_message = "ASG health check type should be EC2"
  }
}

run "verify_security_groups" {
  command = plan

  module {
    source = "./modules/aws/sensor"
  }

  variables {
    vpc_id                  = "vpc-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    corelight_sensor_ami_id = "ami-test123456"
    aws_key_pair_name       = "test-keypair"
    license_key             = "test-license-key"
    community_string        = "test-community-string"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  assert {
    condition     = aws_security_group.monitoring.name == "corelight-sensor-monitoring"
    error_message = "Monitoring security group should have correct default name"
  }

  assert {
    condition     = aws_security_group.management.name == "corelight-sensor-management"
    error_message = "Management security group should have correct default name"
  }

  assert {
    condition     = aws_security_group.monitoring.vpc_id == "vpc-test123456"
    error_message = "Security groups should be created in the specified VPC"
  }
}

run "verify_launch_template_configuration" {
  command = plan

  module {
    source = "./modules/aws/sensor"
  }

  variables {
    vpc_id                  = "vpc-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    corelight_sensor_ami_id = "ami-test123456"
    aws_key_pair_name       = "test-keypair"
    license_key             = "test-license-key"
    community_string        = "test-community-string"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.instance_type == "c5.2xlarge"
    error_message = "Default instance type should be c5.2xlarge"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.image_id == "ami-test123456"
    error_message = "Launch template should use specified AMI ID"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.key_name == "test-keypair"
    error_message = "Launch template should use specified key pair"
  }

  assert {
    condition     = aws_launch_template.sensor_launch_template.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 should be enforced (http_tokens = required)"
  }
}
