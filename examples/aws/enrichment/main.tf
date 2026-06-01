####################################################################################################
# Create the bucket where all enrichment data will be stored
####################################################################################################

# Default provider uses primary_region variable
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "primary"
  region = var.primary_region

  default_tags {
    tags = var.tags
  }
}

resource "aws_s3_bucket" "enrichment_bucket" {
  provider = aws.primary

  bucket = var.bucket_name

}

resource "aws_s3_bucket_public_access_block" "enrichment_bucket_public_access_block" {
  provider = aws.primary

  bucket = aws_s3_bucket.enrichment_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#trivy:ignore:AVD-AWS-0132 AES256 encryption is sufficient for enrichment metadata. Customer managed keys are not required as this data is non-sensitive cloud resource metadata.
resource "aws_s3_bucket_server_side_encryption_configuration" "enrichment_bucket_encryption" {
  provider = aws.primary

  bucket = aws_s3_bucket.enrichment_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

####################################################################################################
# Deploy the lambda and supporting resources for the primary region
####################################################################################################
data "aws_ecr_repository" "enrichment_repo" {
  provider = aws.primary
  name     = var.ecr_repository_name
}

module "enrichment_eventbridge_role" {
  source = "../../../modules/aws/enrichment/submodules/iam/eventbridge"

  primary_event_bus_arn = module.enrichment.primary_event_bus_arn

}

module "enrichment_lambda_role" {
  source = "../../../modules/aws/enrichment/submodules/iam/lambda"

  enrichment_bucket_arn           = aws_s3_bucket.enrichment_bucket.arn
  enrichment_ecr_repository_arn   = data.aws_ecr_repository.enrichment_repo.arn
  lambda_cloudwatch_log_group_arn = module.enrichment.cloudwatch_log_group_arn

}

module "enrichment" {
  source = "../../../modules/aws/enrichment"

  providers = {
    aws = aws.primary
  }

  corelight_cloud_enrichment_image      = var.image_name
  corelight_cloud_enrichment_image_tag  = var.image_tag
  enrichment_bucket_name                = aws_s3_bucket.enrichment_bucket.bucket
  enrichment_bucket_region              = aws_s3_bucket.enrichment_bucket.region
  scheduled_sync_regions                = var.my_regions
  eventbridge_iam_cross_region_role_arn = module.enrichment_eventbridge_role.cross_region_role_arn
  lambda_iam_role_arn                   = module.enrichment_lambda_role.lambda_iam_role_arn
  primary_event_bus_name                = var.primary_event_bus_name

}

####################################################################################################
# Deploy Corelight sensor and assign autoscaling group permission to read from the bucket
####################################################################################################

data "aws_subnet" "management" {
  provider = aws.primary
  id       = var.management_subnet
}

module "asg_lambda_role" {
  source = "../../../modules/aws/sensor/submodules/iam-lambda"

  lambda_cloudwatch_log_group_arn = module.sensor.cloudwatch_log_group_arn
  security_group_arn              = module.sensor.management_security_group_arn
  sensor_autoscaling_group_arn    = module.sensor.autoscaling_group_arn
  subnet_arns                     = [data.aws_subnet.management.arn]
  lambda_role_name                = var.lambda_role_name
  lambda_policy_name              = var.lambda_policy_name

}

module "sensor" {
  source = "../../../modules/aws/sensor"

  # Required variables
  vpc_id                  = var.vpc_id
  corelight_sensor_ami_id = var.sensor_ami_id
  monitoring_subnet_ids   = [var.monitoring_subnet]
  management_subnet_ids   = [var.management_subnet]
  aws_key_pair_name       = var.sensor_ssh_key_pair_name
  community_string        = var.community_string
  license_key_file_path   = var.license_key_file
  asg_lambda_iam_role_arn = module.asg_lambda_role.role_arn

  # Fleet configuration
  fleet_url            = var.fleet_url
  fleet_token          = var.fleet_token
  fleet_server_sslname = var.fleet_server_sslname

  # Enrichment instance profile for S3 access
  instance_profile_arn = aws_iam_instance_profile.corelight_sensor.arn

  # Resource naming (to avoid conflicts)
  sensor_asg_load_balancer_name         = var.sensor_asg_load_balancer_name
  lb_health_check_target_group_name     = var.lb_health_check_target_group_name
  sensor_monitoring_security_group_name = var.sensor_monitoring_security_group_name
  sensor_management_security_group_name = var.sensor_management_security_group_name
  sensor_launch_template_name           = var.sensor_launch_template_name
  lambda_function_name                  = var.lambda_function_name

}

module "sensor_iam" {
  source = "../../../modules/aws/enrichment/submodules/iam/sensor"

  enrichment_bucket_arn = aws_s3_bucket.enrichment_bucket.arn

}

resource "aws_iam_instance_profile" "corelight_sensor" {
  name = "corelight-sensor-profile"
  role = module.sensor_iam.sensor_role_name

}

####################################################################################################
# Setup providers and deploy the "Fan In" event bus resources in each secondary region
####################################################################################################

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"

  default_tags {
    tags = var.tags
  }
}


module "secondary_eventbridge_rule_us-east-2" {
  source = "../../../modules/aws/enrichment/submodules/secondary-event-rule"

  providers = {
    aws = aws.us-east-2
  }

  cross_region_eventbridge_role_arn    = module.enrichment_eventbridge_role.cross_region_role_arn
  primary_event_bus_arn                = module.enrichment.primary_event_bus_arn
  secondary_ec2_state_change_rule_name = "${var.secondary_rule_name}-us-east-2"

}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"

  default_tags {
    tags = var.tags
  }
}

module "secondary_eventbridge_rule_us-west-1" {
  source = "../../../modules/aws/enrichment/submodules/secondary-event-rule"

  providers = {
    aws = aws.us-west-1
  }

  cross_region_eventbridge_role_arn    = module.enrichment_eventbridge_role.cross_region_role_arn
  primary_event_bus_arn                = module.enrichment.primary_event_bus_arn
  secondary_ec2_state_change_rule_name = "${var.secondary_rule_name}-us-west-1"

}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"

  default_tags {
    tags = var.tags
  }
}

module "secondary_eventbridge_rule_us-west-2" {
  source = "../../../modules/aws/enrichment/submodules/secondary-event-rule"

  providers = {
    aws = aws.us-west-2
  }

  cross_region_eventbridge_role_arn    = module.enrichment_eventbridge_role.cross_region_role_arn
  primary_event_bus_arn                = module.enrichment.primary_event_bus_arn
  secondary_ec2_state_change_rule_name = "${var.secondary_rule_name}-us-west-2"

}
