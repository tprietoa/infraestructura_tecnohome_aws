# Modulo rds: Amazon RDS MySQL Multi-AZ, cifrada
resource "aws_db_subnet_group" "db" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.name_prefix}-db-subnet-group" }
}

resource "aws_db_instance" "tecnohome" {
  identifier              = "${var.name_prefix}-rds"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 50
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [var.sg_db_id]
  multi_az                = var.db_multi_az
  backup_retention_period = var.backup_retention_days
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  tags                    = { Name = "${var.name_prefix}-rds" }
}
