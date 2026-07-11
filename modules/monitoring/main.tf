# Modulo monitoring: SNS, alarmas y dashboard
resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
  tags = { Name = "${var.name_prefix}-alerts" }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "cpu70" {
  alarm_name          = "${var.name_prefix}-alarm-cpu70"
  alarm_description   = "CPU promedio del ASG > 70%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { AutoScalingGroupName = var.asg_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "mem70" {
  alarm_name          = "${var.name_prefix}-alarm-mem70"
  alarm_description   = "RAM promedio del ASG > 70%"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  dimensions          = { AutoScalingGroupName = var.asg_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_conexiones" {
  alarm_name          = "${var.name_prefix}-alarm-rds-conexiones"
  alarm_description   = "RDS conexiones activas altas"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 68
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_almacenamiento" {
  alarm_name          = "${var.name_prefix}-alarm-rds-almacenamiento"
  alarm_description   = "RDS espacio libre < 20% (10 GB)"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10737418240
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "${var.name_prefix}-alarm-alb-unhealthy"
  alarm_description   = "ALB hosts no sanos (frontend)"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.tg_front_arn_suffix
  }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name_prefix}-alarm-alb-5xx"
  alarm_description   = "ALB errores 5XX elevados"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          title   = "EC2 - CPU promedio del ASG"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 60
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6,
        properties = {
          title   = "EC2 - Memoria usada (CloudWatch Agent)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 60
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["CWAgent", "mem_used_percent", "AutoScalingGroupName", var.asg_name]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6,
        properties = {
          title   = "EC2 - Disco usado (CloudWatch Agent)"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 60
          yAxis   = { left = { min = 0, max = 100 } }
          metrics = [["CWAgent", "disk_used_percent", "AutoScalingGroupName", var.asg_name, "path", "/"]]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6,
        properties = {
          title  = "ALB - Peticiones y Latencia"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "Average", yAxis = "right" }]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 12, width = 12, height = 6,
        properties = {
          title  = "ALB - Hosts sanos por Target Group"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.tg_front_arn_suffix, "LoadBalancer", var.alb_arn_suffix],
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.tg_back_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 12, width = 12, height = 6,
        properties = {
          title  = "RDS - CPU y Conexiones"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier, { stat = "Average" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier, { stat = "Average", yAxis = "right" }]
          ]
        }
      }
    ]
  })
}
