resource "aws_sns_topic" "alarm_topic" {
  name = "high-cpu-alert-topic"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  count     = length(var.alert_email)
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email[count.index]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  provider              = aws
  alarm_name            = "high-cpu"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = 2
  metric_name           = "CPUUtilization"
  namespace             = "AWS/EC2"
  period                = 60
  statistic             = "Average"
  threshold             = 40
  alarm_description     = "Alarm if CPU > 40% for 2 minutes"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}
