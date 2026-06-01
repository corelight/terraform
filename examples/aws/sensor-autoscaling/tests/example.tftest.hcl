# Unit tests for AWS Sensor Auto-Scaling Example
# These tests validate the example configuration

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

run "verify_deployment_name_propagation" {
  command = plan

  variables {
    deployment_name          = "test-deployment"
    vpc_id                   = "vpc-test123456"
    monitoring_subnet_ids    = ["subnet-mon123456"]
    management_subnet_ids    = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name = "test-keypair"
    sensor_ami_id            = "ami-test123456"
    community_string         = "test-community"
    fleet_url                = "https://fleet.example.com"
  }

  assert {
    condition     = module.sensor.autoscaling_group_name == "test-deployment-asg"
    error_message = "ASG name should include deployment_name"
  }
}

run "verify_custom_resource_names" {
  command = plan

  variables {
    deployment_name                   = "custom"
    vpc_id                            = "vpc-test123456"
    monitoring_subnet_ids             = ["subnet-mon123456"]
    management_subnet_ids             = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name          = "test-keypair"
    sensor_ami_id                     = "ami-test123456"
    community_string                  = "test-community"
    fleet_url                         = "https://fleet.example.com"
    sensor_asg_name                   = "my-custom-asg"
    sensor_instance_name              = "my-custom-sensor"
    sensor_launch_template_name       = "my-custom-template"
    sensor_asg_load_balancer_name     = "my-custom-lb"
    lb_health_check_target_group_name = "my-custom-tg"
  }

  assert {
    condition     = module.sensor.autoscaling_group_name == "my-custom-asg"
    error_message = "Custom ASG name should be respected"
  }
}

run "verify_fleet_optional" {
  command = plan

  variables {
    deployment_name          = "test"
    vpc_id                   = "vpc-test123456"
    monitoring_subnet_ids    = ["subnet-mon123456"]
    management_subnet_ids    = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name = "test-keypair"
    sensor_ami_id            = "ami-test123456"
    fleet_url                = "https://fleet.example.com"
    community_string         = "test-community"
  }

  assert {
    condition     = module.sensor.autoscaling_group_name != ""
    error_message = "Sensor should be deployable without Fleet"
  }
}

run "verify_multi_az_support" {
  command = plan

  variables {
    deployment_name          = "multi-az"
    vpc_id                   = "vpc-test123456"
    monitoring_subnet_ids    = ["subnet-mon123456"]
    management_subnet_ids    = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name = "test-keypair"
    sensor_ami_id            = "ami-test123456"
    community_string         = "test-community"
    fleet_url                = "https://fleet.example.com"
  }

  assert {
    condition     = module.sensor.autoscaling_group_name == "multi-az-asg"
    error_message = "Should support deployment name in multi-AZ configuration"
  }
}

run "verify_tags_propagation" {
  command = plan

  variables {
    deployment_name          = "tagged"
    vpc_id                   = "vpc-test123456"
    monitoring_subnet_ids    = ["subnet-mon123456"]
    management_subnet_ids    = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name = "test-keypair"
    sensor_ami_id            = "ami-test123456"
    community_string         = "test-community"
    fleet_url                = "https://fleet.example.com"
    tags = {
      Environment = "test"
      Project     = "corelight"
      Owner       = "platform-team"
    }
  }

  assert {
    condition     = module.sensor.autoscaling_group_name != ""
    error_message = "Resources should be created with custom tags"
  }
}

run "verify_outputs" {
  command = plan

  variables {
    deployment_name          = "test"
    vpc_id                   = "vpc-test123456"
    monitoring_subnet_ids    = ["subnet-mon123456"]
    management_subnet_ids    = ["subnet-mgmt123456"]
    sensor_ssh_key_pair_name = "test-keypair"
    sensor_ami_id            = "ami-test123456"
    community_string         = "test-community"
    fleet_url                = "https://fleet.example.com"
  }

  assert {
    condition     = output.autoscaling_group_name == "test-asg"
    error_message = "Should output ASG name matching deployment"
  }
}
