resource "aws_autoscaling_group" "ctfd_asg" {
  name               = "ctfd_asg"
  availability_zones = var.availability_zones
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  health_check_type = "ELB"
  target_group_arns = [var.target_group_arns]

  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  depends_on = [var.asg_depends_on]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ctfd-scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ctfd_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ctfd_high_cpu" {
  alarm_name          = "ctfd_high_cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.scale_up_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ctfd_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ctfd-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ctfd_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ctfd_low_cpu" {
  alarm_name          = "ctfd_low_cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.scale_down_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ctfd_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

