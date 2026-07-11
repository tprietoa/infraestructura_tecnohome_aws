# Modulo security: SGs en cadena Internet -> ALB -> WEB -> DB
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "ALB: HTTP 80 y backend 3001 desde Internet"
  vpc_id      = var.vpc_id
  ingress {
    description = "HTTP frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Backend API"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-alb" }
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-sg-web"
  description = "EC2 Web/App: 80 y 3001 solo desde SG-ALB"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Frontend desde ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    description     = "Backend desde ALB"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-web" }
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "RDS MySQL: 3306 solo desde SG-WEB"
  vpc_id      = var.vpc_id
  ingress {
    description     = "MySQL desde SG-WEB"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-db" }
}
