variable "name_prefix" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "sg_db_id" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_instance_class" { type = string }
variable "db_multi_az" { type = bool }
variable "backup_retention_days" { type = number }
