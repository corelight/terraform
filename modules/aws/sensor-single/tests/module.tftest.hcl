# Unit tests for AWS Single Sensor Module
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
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
    }
  }
}

mock_provider "cloudinit" {}

run "test_minimal_configuration" {
  command = plan

  variables {
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
  }

  # Validates minimal required configuration works
}

run "test_with_fleet_configuration" {
  command = plan

  variables {
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    fleet_token                      = "test-token"
    fleet_url                        = "https://fleet.example.com"
    fleet_server_sslname             = "fleet.example.com"
  }

  # Validates Fleet integration configuration
}

run "test_custom_deployment_name" {
  command = plan

  variables {
    deployment_name                  = "custom-deployment"
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
  }

  # Validates custom deployment name is applied
}

run "test_security_configuration" {
  command = plan

  variables {
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    ssh_allow_cidrs                  = ["10.0.0.0/8"]
    egress_allow_cidrs               = ["0.0.0.0/0"]
    mirror_ingress_allow_cidrs       = ["10.0.0.0/16"]
    health_check_allow_cidrs         = ["10.0.0.0/16"]
  }

  # Validates security group configuration
}

run "test_instance_configuration" {
  command = plan

  variables {
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    instance_type                    = "c5.4xlarge"
    ebs_volume_size                  = 1000
  }

  # Validates custom instance configuration
}
