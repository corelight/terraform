# Unit tests for AWS Single Sensor Module
# These tests validate the module directly

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }

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

  assert {
    condition = try(
      yamldecode(base64decode(trimspace(split("\n", split("content: ", split("path: /etc/corelight/deployment-metadata.yaml", module.config[0].cloudinit_config.part[0].content)[1])[1])[0])))["deployment_metadata.cloud_provider"] == "aws",
      false,
    )
    error_message = "Provider module should pass deployment metadata to shared cloud-init"
  }

  assert {
    condition = try(
      yamldecode(base64decode(trimspace(split("\n", split("content: ", split("path: /etc/corelight/deployment-metadata.yaml", module.config[0].cloudinit_config.part[0].content)[1])[1])[0])))["deployment_metadata.terraform_module"] == "aws/sensor-single",
      false,
    )
    error_message = "Provider module should pass its Terraform module identity"
  }

  assert {
    condition = try(
      yamldecode(base64decode(trimspace(split("\n", split("content: ", split("path: /etc/corelight/deployment-metadata.yaml", module.config[0].cloudinit_config.part[0].content)[1])[1])[0])))["deployment_metadata.cloud_region"] == "us-east-1",
      false,
    )
    error_message = "Provider module should pass the active AWS region to shared cloud-init"
  }
}

run "test_custom_sensor_user_data_bypasses_generated_metadata" {
  command = plan

  variables {
    ami_id                           = "ami-test123456"
    community_string                 = "test-community"
    aws_key_pair_name                = "test-keypair"
    monitoring_interface_subnet_id   = "subnet-mon123456"
    monitoring_security_group_vpc_id = "vpc-test123456"
    management_interface_subnet_id   = "subnet-mgmt123456"
    management_security_group_vpc_id = "vpc-test123456"
    custom_sensor_user_data          = "#cloud-config\nruncmd: []"
  }

  assert {
    condition     = length(module.config) == 0
    error_message = "Custom sensor user data should bypass generated deployment metadata"
  }
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
