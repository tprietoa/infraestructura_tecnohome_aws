# Modulo alb: ALB, Target Groups y Listeners
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.name_prefix}-alb" }
}

resource "aws_lb_target_group" "front" {
  name     = "${var.name_prefix}-tg-front"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = { Name = "${var.name_prefix}-tg-front" }
}

resource "aws_lb_target_group" "back" {
  name     = "${var.name_prefix}-tg-back"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/api/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = { Name = "${var.name_prefix}-tg-back" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3001
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }
}
