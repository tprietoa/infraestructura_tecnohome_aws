# Modulo compute: Launch Template, ASG y politica de escalado
resource "aws_launch_template" "lt" {
  name          = "${var.name_prefix}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }
  vpc_security_group_ids = [var.sg_web_id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region   = var.aws_region
    ecr_registry = var.ecr_registry
    db_host      = var.db_host
    db_user      = var.db_username
    db_password  = var.db_password
    db_name      = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.name_prefix}-asg" })
  }
  tags = { Name = "${var.name_prefix}-lt" }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.asg_min
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  vpc_zone_identifier       = var.public_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = var.target_group_arns

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, { Name = "${var.name_prefix}-asg" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.name_prefix}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_tracking
  }
}
