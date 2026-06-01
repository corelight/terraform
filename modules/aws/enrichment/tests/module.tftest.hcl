mock_provider "aws" {}

variables {
  corelight_cloud_enrichment_image      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test-enrichment"
  corelight_cloud_enrichment_image_tag  = "latest"
  enrichment_bucket_name                = "test-enrichment-bucket"
  enrichment_bucket_region              = "us-east-1"
  lambda_iam_role_arn                   = "arn:aws:iam::123456789012:role/test-lambda-role"
  eventbridge_iam_cross_region_role_arn = "arn:aws:iam::123456789012:role/test-eventbridge-role"
}

run "verify_lambda_function" {
  command = plan

  assert {
    condition     = aws_lambda_function.enrichment_lambda.function_name == "corelight-aws-cloud-enrichment"
    error_message = "Lambda function name should be corelight-aws-cloud-enrichment"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.package_type == "Image"
    error_message = "Lambda should use Image package type"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.timeout == 60
    error_message = "Lambda timeout should be 60 seconds by default"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.architectures[0] == "arm64"
    error_message = "Lambda should use arm64 architecture by default"
  }
}

run "verify_lambda_environment_variables" {
  command = plan

  assert {
    condition     = aws_lambda_function.enrichment_lambda.environment[0].variables["BUCKET_NAME"] == "test-enrichment-bucket"
    error_message = "Lambda should have correct BUCKET_NAME environment variable"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.environment[0].variables["BUCKET_REGION"] == "us-east-1"
    error_message = "Lambda should have correct BUCKET_REGION environment variable"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.environment[0].variables["PREFIX"] == "corelight"
    error_message = "Lambda should have correct PREFIX environment variable"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.environment[0].variables["LOG_LEVEL"] == "info"
    error_message = "Lambda should have info log level by default"
  }
}

run "verify_primary_event_bus" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_bus.primary_bus.name == "corelight-primary-event-bus"
    error_message = "Primary event bus should have correct default name"
  }
}

run "verify_ec2_state_change_rule" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.ec2_state_change_primary_rule.name == "corelight-ec2-state-change-rule"
    error_message = "EC2 state change rule should have correct default name"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.ec2_state_change_primary_rule.event_bus_name == aws_cloudwatch_event_bus.primary_bus.name
    error_message = "EC2 state change rule should use primary event bus"
  }
}

run "verify_scheduled_sync_rule" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.scheduled_enrichment_trigger.name == "every-15-minutes"
    error_message = "Scheduled sync rule should have correct default name"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.scheduled_enrichment_trigger.schedule_expression == "rate(15 minutes)"
    error_message = "Scheduled sync should run every 15 minutes by default"
  }
}

run "verify_cloudwatch_log_group" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.log_group.retention_in_days == 3
    error_message = "CloudWatch log group should have 3 days retention by default"
  }

  assert {
    condition     = startswith(aws_cloudwatch_log_group.log_group.name, "/aws/lambda/")
    error_message = "CloudWatch log group should be in /aws/lambda/ namespace"
  }
}

run "verify_custom_lambda_name" {
  command = plan

  variables {
    lambda_name = "custom-enrichment-lambda"
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.function_name == "custom-enrichment-lambda"
    error_message = "Lambda function name should be customizable"
  }
}

run "verify_custom_scheduled_sync_frequency" {
  command = plan

  variables {
    scheduled_sync_rule_frequency = 30
  }

  assert {
    condition     = aws_cloudwatch_event_rule.scheduled_enrichment_trigger.name == "every-30-minutes"
    error_message = "Scheduled sync rule name should reflect custom frequency"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.scheduled_enrichment_trigger.schedule_expression == "rate(30 minutes)"
    error_message = "Scheduled sync frequency should be customizable"
  }
}

run "verify_custom_event_bus_name" {
  command = plan

  variables {
    primary_event_bus_name = "custom-event-bus"
  }

  assert {
    condition     = aws_cloudwatch_event_bus.primary_bus.name == "custom-event-bus"
    error_message = "Event bus name should be customizable"
  }
}

run "verify_custom_regions" {
  command = plan

  variables {
    scheduled_sync_regions = ["us-east-1", "us-west-2"]
  }

  assert {
    condition     = aws_lambda_function.enrichment_lambda.environment[0].variables["REGIONS"] == "us-east-1,us-west-2"
    error_message = "Lambda should have custom regions in environment variable"
  }
}

run "verify_lambda_permissions" {
  command = plan

  assert {
    condition     = aws_lambda_permission.ec2_state_change_event_bridge_trigger_permission.principal == "events.amazonaws.com"
    error_message = "Lambda should allow EventBridge to invoke it"
  }

  assert {
    condition     = aws_lambda_permission.cron_event_bridge_trigger_permission.principal == "events.amazonaws.com"
    error_message = "Lambda should allow scheduled EventBridge rule to invoke it"
  }
}
