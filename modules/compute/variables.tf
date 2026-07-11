variable "name_prefix" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "instance_profile_name" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "sg_web_id" { type = string }
variable "target_group_arns" { type = list(string) }
variable "aws_region" { type = string }
variable "ecr_registry" { type = string }
variable "db_host" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_name" { type = string }
variable "asg_min" { type = number }
variable "asg_desired" { type = number }
variable "asg_max" { type = number }
variable "cpu_target_tracking" { type = number }
variable "common_tags" { type = map(string) }
