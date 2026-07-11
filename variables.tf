
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/22"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "ami_id" {
  type    = string
  default = ""
}
variable "instance_profile_name" {
  type    = string
  default = "LabInstanceProfile"
}
variable "asg_min" {
  type    = number
  default = 2
}
variable "asg_desired" {
  type    = number
  default = 2
}
variable "asg_max" {
  type    = number
  default = 4
}
variable "cpu_target_tracking" {
  type    = number
  default = 70
}

variable "db_name" {
  type    = string
  default = "tienda_productos"
}
variable "db_username" {
  type    = string
  default = "admin"
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "db_multi_az" {
  type    = bool
  default = true
}
variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "entorno" {
  type    = string
  default = "Produccion"
}
variable "responsable" {
  type    = string
  default = "Servando Soto"
}
variable "centro_de_costo" {
  type    = string
  default = "TECNOHOME-IT"
}

variable "alert_email" {
  type    = string
  default = "servando.soto@solutivati.cl"
}
variable "backup_role_arn" {
  type    = string
  default = ""
}
