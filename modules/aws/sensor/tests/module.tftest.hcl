# Unit tests for AWS Sensor Auto-Scaling Module
# These tests validate the module directly

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

run "test_minimal_configuration" {
  command = plan

  variables {
    vpc_id                  = "vpc-test123456"
    corelight_sensor_ami_id = "ami-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    aws_key_pair_name       = "test-keypair"
    community_string        = "test-community"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  # Validates minimal required configuration works
}

run "test_with_fleet_configuration" {
  command = plan

  variables {
    vpc_id                  = "vpc-test123456"
    corelight_sensor_ami_id = "ami-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    aws_key_pair_name       = "test-keypair"
    community_string        = "test-community"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
    fleet_http_proxy        = "http://proxy:8080"
    fleet_https_proxy       = "https://proxy:8443"
  }

  # Validates Fleet integration with proxy configuration
}

run "test_custom_resource_names" {
  command = plan

  variables {
    vpc_id                            = "vpc-test123456"
    corelight_sensor_ami_id           = "ami-test123456"
    monitoring_subnet_ids             = ["subnet-mon123456"]
    management_subnet_ids             = ["subnet-mgmt123456"]
    aws_key_pair_name                 = "test-keypair"
    community_string                  = "test-community"
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

  # Validates custom resource naming
}

run "test_multi_az_configuration" {
  command = plan

  variables {
    vpc_id                  = "vpc-test123456"
    corelight_sensor_ami_id = "ami-test123456"
    monitoring_subnet_ids   = ["subnet-mon123", "subnet-mon456", "subnet-mon789"]
    management_subnet_ids   = ["subnet-mgmt123", "subnet-mgmt456", "subnet-mgmt789"]
    aws_key_pair_name       = "test-keypair"
    community_string        = "test-community"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
  }

  override_data {
    target = data.aws_subnet.management_subnets["subnet-mgmt123"]
    values = {
      availability_zone = "us-east-1a"
      id                = "subnet-mgmt123"
    }
  }

  override_data {
    target = data.aws_subnet.management_subnets["subnet-mgmt456"]
    values = {
      availability_zone = "us-east-1b"
      id                = "subnet-mgmt456"
    }
  }

  override_data {
    target = data.aws_subnet.management_subnets["subnet-mgmt789"]
    values = {
      availability_zone = "us-east-1c"
      id                = "subnet-mgmt789"
    }
  }

  # Validates multi-AZ deployment configuration
}

run "test_scaling_configuration" {
  command = plan

  variables {
    vpc_id                    = "vpc-test123456"
    corelight_sensor_ami_id   = "ami-test123456"
    monitoring_subnet_ids     = ["subnet-mon123456"]
    management_subnet_ids     = ["subnet-mgmt123456"]
    aws_key_pair_name         = "test-keypair"
    community_string          = "test-community"
    asg_lambda_iam_role_arn   = "arn:aws:iam::123456789012:role/test-role"
    fleet_token               = "test-token"
    fleet_url                 = "https://fleet.example.com"
    fleet_server_sslname      = "fleet.example.com"
    sensor_asg_min_size       = 2
    sensor_asg_max_size       = 10
    sensor_asg_desired_size   = 4
    sensor_instance_disk_size = 1000
    sensor_instance_type      = "c5.4xlarge"
  }

  # Validates auto-scaling and instance configuration
}

run "test_security_configuration" {
  command = plan

  variables {
    vpc_id                  = "vpc-test123456"
    corelight_sensor_ami_id = "ami-test123456"
    monitoring_subnet_ids   = ["subnet-mon123456"]
    management_subnet_ids   = ["subnet-mgmt123456"]
    aws_key_pair_name       = "test-keypair"
    community_string        = "test-community"
    asg_lambda_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    fleet_token             = "test-token"
    fleet_url               = "https://fleet.example.com"
    fleet_server_sslname    = "fleet.example.com"
    kms_key_id              = "arn:aws:kms:us-east-1:123456789012:key/test-key"
  }

  # Validates security configuration with KMS encryption
}
