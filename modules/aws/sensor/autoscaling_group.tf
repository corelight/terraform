resource "aws_autoscaling_group" "sensor_asg" {
  name             = var.sensor_asg_name
  min_size         = var.sensor_asg_min_size
  max_size         = var.sensor_asg_max_size
  desired_capacity = var.sensor_asg_desired_capacity

  launch_template {
    name    = aws_launch_template.sensor_launch_template.name
    version = aws_launch_template.sensor_launch_template.latest_version
  }

  vpc_zone_identifier       = var.monitoring_subnet_ids
  target_group_arns         = [aws_lb_target_group.health_check.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 900
  default_instance_warmup   = 900
  termination_policies      = ["OldestInstance"]
  protect_from_scale_in     = false
  wait_for_capacity_timeout = 0

  initial_lifecycle_hook {
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    name                 = var.asg_lifecycle_hook_name
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
  }

  tag {
    key                 = "Name"
    value               = var.sensor_instance_name
    propagate_at_launch = true
  }

  depends_on = [
    aws_lambda_function.auto_scaling_lambda,
    aws_cloudwatch_event_rule.asg_lifecycle_rule,
    aws_cloudwatch_log_group.log_group,
  ]
}

resource "aws_autoscaling_policy" "sensor_autoscale_policy" {
  name                   = var.sensor_asg_auto_scale_policy_name
  autoscaling_group_name = aws_autoscaling_group.sensor_asg.name

  policy_type     = "StepScaling"
  adjustment_type = "ChangeInCapacity"
  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sensor_asg_high_cpu_alarm" {
  alarm_name          = "${var.sensor_asg_name}-high-cpu"
  alarm_description   = "Scale out if CPU > 70% for 2 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.sensor_autoscale_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sensor_asg.name
  }
}

resource "aws_autoscaling_policy" "sensor_scale_in_policy" {
  name                   = var.sensor_asg_scale_in_policy_name
  autoscaling_group_name = aws_autoscaling_group.sensor_asg.name

  policy_type     = "StepScaling"
  adjustment_type = "ChangeInCapacity"
  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}

resource "aws_cloudwatch_metric_alarm" "sensor_asg_low_cpu_alarm" {
  alarm_name          = "${var.sensor_asg_name}-low-cpu"
  alarm_description   = "Scale in if CPU < 30% for 5 minutes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.sensor_scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sensor_asg.name
  }
}