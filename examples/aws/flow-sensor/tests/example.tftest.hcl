# Unit tests for AWS Flow Sensor Example
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
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
    }
  }
}

mock_provider "cloudinit" {}

run "verify_default_configuration" {
  command = plan

  variables {
    deployment_name                  = "test-flow-sensor"
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    license_key_file_path            = ""
    vpc_flow_logs_bucket_arn         = "arn:aws:s3:::test-vpc-flow-logs"
  }

  # Tests verify the plan succeeds with default configuration
}

run "verify_with_cross_account_role" {
  command = plan

  variables {
    deployment_name                  = "test-flow-sensor"
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    license_key_file_path            = ""
    vpc_flow_logs_bucket_arn         = "arn:aws:s3:::test-vpc-flow-logs"
    cross_account_role_name          = "corelight-vpc-flow-cross-account-role"
  }

  # Tests verify the plan succeeds with cross-account access enabled
}

run "verify_with_ssh_restrictions" {
  command = plan

  variables {
    deployment_name                  = "test-flow-sensor"
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    license_key_file_path            = ""
    vpc_flow_logs_bucket_arn         = "arn:aws:s3:::test-vpc-flow-logs"
    ssh_allow_cidrs                  = ["10.0.0.0/8", "192.168.1.0/24"]
  }

  # Tests verify the plan succeeds with SSH restrictions
}
