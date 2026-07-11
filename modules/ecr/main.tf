# Modulo ecr: repos privados frontend y backend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.name_prefix}-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "${var.name_prefix}-frontend" }
}
resource "aws_ecr_repository" "backend" {
  name                 = "${var.name_prefix}-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "${var.name_prefix}-backend" }
}
