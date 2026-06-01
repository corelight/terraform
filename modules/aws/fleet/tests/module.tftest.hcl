# Unit tests for AWS Fleet Module
# These tests validate the module configuration without deploying real infrastructure

mock_provider "aws" {
  mock_data "aws_route53_zone" {
    defaults = {
      arn                       = "arn:aws:route53:::hostedzone/Z1234567890ABC"
      id                        = "Z1234567890ABC"
      name                      = "example.com"
      name_servers              = ["ns-1.awsdns-01.com", "ns-2.awsdns-02.net"]
      zone_id                   = "Z1234567890ABC"
      resource_record_set_count = 10
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id                  = "ami-0c55b159cbfafe1f0"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20231201"
      architecture        = "x86_64"
      root_device_name    = "/dev/sda1"
      virtualization_type = "hvm"
    }
  }
}

mock_provider "cloudinit" {}

run "verify_required_variables" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_instance.fleet_instance.instance_type == "t3.large"
    error_message = "Default instance type should be t3.large"
  }

  assert {
    condition     = aws_lb.fleet_alb.name == "corelight-fleet-alb"
    error_message = "ALB name should default to 'corelight-fleet-alb'"
  }

  assert {
    condition     = aws_instance.fleet_instance.tags["Name"] == "corelight-fleet"
    error_message = "Instance name should default to 'corelight-fleet'"
  }
}

run "verify_custom_names" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    fleet_instance_name            = "custom-fleet"
    fleet_alb_name                 = "custom-alb"
    fleet_lb_target_group_name     = "custom-tg"
  }

  assert {
    condition     = aws_instance.fleet_instance.tags["Name"] == "custom-fleet"
    error_message = "Instance name should be customizable"
  }

  assert {
    condition     = aws_lb.fleet_alb.name == "custom-alb"
    error_message = "ALB name should be customizable"
  }

  assert {
    condition     = aws_lb_target_group.fleet_tg.name == "custom-tg"
    error_message = "Target group name should be customizable"
  }
}

run "verify_instance_configuration" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    aws_ec2_size                   = "t3.xlarge"
    aws_volume_size                = 100
  }

  assert {
    condition     = aws_instance.fleet_instance.instance_type == "t3.xlarge"
    error_message = "Instance type should be customizable"
  }

  assert {
    condition     = aws_instance.fleet_instance.root_block_device[0].volume_size == 100
    error_message = "Volume size should be customizable"
  }

  assert {
    condition     = aws_instance.fleet_instance.root_block_device[0].encrypted == true
    error_message = "Root volume should be encrypted"
  }

  assert {
    condition     = aws_instance.fleet_instance.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 should be enforced (http_tokens = required)"
  }
}

run "verify_alb_configuration" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_lb.fleet_alb.load_balancer_type == "application"
    error_message = "Load balancer should be application type"
  }

  assert {
    condition     = aws_lb.fleet_alb.internal == false
    error_message = "ALB should be internet-facing by default"
  }

  assert {
    condition     = aws_lb.fleet_alb.drop_invalid_header_fields == true
    error_message = "ALB should drop invalid header fields for security"
  }

  assert {
    condition     = length(aws_lb.fleet_alb.subnets) == 2
    error_message = "ALB should be deployed in multiple subnets"
  }
}

run "verify_alb_listeners" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_lb_listener.https.port == 443
    error_message = "HTTPS listener should be on port 443"
  }

  assert {
    condition     = aws_lb_listener.https.protocol == "HTTPS"
    error_message = "Listener should use HTTPS protocol"
  }

  assert {
    condition     = aws_lb_listener.https.ssl_policy == "ELBSecurityPolicy-TLS-1-2-2017-01"
    error_message = "Should use secure TLS policy"
  }

  assert {
    condition     = aws_lb_listener.https_1443.port == 1443
    error_message = "API listener should be on port 1443"
  }

  assert {
    condition     = aws_lb_listener.https_1443.protocol == "HTTPS"
    error_message = "API listener should use HTTPS protocol"
  }
}

run "verify_target_groups" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_lb_target_group.fleet_tg.port == 443
    error_message = "Fleet web UI target group should use port 443"
  }

  assert {
    condition     = aws_lb_target_group.fleet_tg.protocol == "HTTPS"
    error_message = "Target group should use HTTPS protocol"
  }

  assert {
    condition     = aws_lb_target_group.fleet_tg.health_check[0].protocol == "HTTPS"
    error_message = "Health check should use HTTPS"
  }

  assert {
    condition     = aws_lb_target_group.fleet_api_tg.port == 1443
    error_message = "Fleet API target group should use port 1443"
  }

  assert {
    condition     = aws_lb_target_group.fleet_api_tg.health_check[0].matcher == "404"
    error_message = "API health check should expect 404 response"
  }
}

run "verify_security_groups_created" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_security_group.alb_security_group[0].name == "corelight-fleet-alb-security-group"
    error_message = "ALB security group should have correct default name"
  }

  assert {
    condition     = aws_security_group.instance_security_group[0].name == "corelight-fleet-instance-security-group"
    error_message = "Instance security group should have correct default name"
  }

  assert {
    condition     = aws_security_group.alb_security_group[0].vpc_id == "vpc-test123456"
    error_message = "Security groups should be created in the specified VPC"
  }
}

run "verify_security_groups_with_existing" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    alb_security_group_id          = "sg-existing-alb"
    instance_security_group_id     = "sg-existing-instance"
  }

  assert {
    condition     = length(aws_security_group.alb_security_group) == 0
    error_message = "Should not create ALB security group when existing ID is provided"
  }

  assert {
    condition     = length(aws_security_group.instance_security_group) == 0
    error_message = "Should not create instance security group when existing ID is provided"
  }
}

run "verify_route53_dns" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = aws_route53_record.fleet_domain.name == "fleet.example.com"
    error_message = "Route53 record should combine subdomain and zone name"
  }

  assert {
    condition     = aws_route53_record.fleet_domain.type == "A"
    error_message = "Route53 record should be an A record"
  }
}

run "verify_admin_cidr_blocks" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    admin_cidr_blocks              = ["203.0.113.0/24"]
  }

  assert {
    condition     = length(aws_security_group_rule.instance_admin_ingress) == 1
    error_message = "Should create admin ingress rule when CIDR blocks are provided"
  }
}

run "verify_no_admin_cidr_blocks" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    admin_cidr_blocks              = []
  }

  assert {
    condition     = length(aws_security_group_rule.instance_admin_ingress) == 0
    error_message = "Should not create admin ingress rule when no CIDR blocks are provided"
  }
}

run "verify_custom_ami_id" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
    fleet_ami_id                   = "ami-custom12345"
  }

  assert {
    condition     = aws_instance.fleet_instance.ami == "ami-custom12345"
    error_message = "Should use provided custom AMI ID"
  }

  assert {
    condition     = length(data.aws_ami.ubuntu_ami) == 0
    error_message = "Should not look up Ubuntu AMI when custom AMI is provided"
  }
}

run "verify_default_ami_lookup" {
  command = plan

  module {
    source = "./."
  }

  variables {
    vpc_id                         = "vpc-test123456"
    public_subnets                 = ["subnet-pub1", "subnet-pub2"]
    private_subnet                 = "subnet-priv1"
    route53_zone_name              = "example.com"
    subdomain                      = "fleet"
    certificate_arn                = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    aws_key_pair_name              = "test-keypair"
    community_string               = "test-community"
    fleet_username                 = "admin"
    fleet_password                 = "test-password"
    fleet_certificate_file_path    = "./tests/test-cert.pem"
    fleet_sensor_license_file_path = "./tests/test-license.txt"
  }

  assert {
    condition     = length(data.aws_ami.ubuntu_ami) == 1
    error_message = "Should look up Ubuntu AMI when no custom AMI is provided"
  }

  assert {
    condition     = aws_instance.fleet_instance.ami == data.aws_ami.ubuntu_ami[0].id
    error_message = "Should use looked-up Ubuntu AMI when no custom AMI is provided"
  }
}
