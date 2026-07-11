
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  ami_id       = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023.value
  ecr_registry = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

module "network" {
  source               = "./modules/network"
  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source      = "./modules/security"
  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "ecr" {
  source      = "./modules/ecr"
  name_prefix = local.name_prefix
}

module "rds" {
  source                = "./modules/rds"
  name_prefix           = local.name_prefix
  private_subnet_ids    = module.network.private_subnet_ids
  sg_db_id              = module.security.sg_db_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_multi_az           = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
}

module "alb" {
  source            = "./modules/alb"
  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  sg_alb_id         = module.security.sg_alb_id
}

module "compute" {
  source                = "./modules/compute"
  name_prefix           = local.name_prefix
  ami_id                = local.ami_id
  instance_type         = var.instance_type
  instance_profile_name = var.instance_profile_name
  public_subnet_ids     = module.network.public_subnet_ids
  sg_web_id             = module.security.sg_web_id
  target_group_arns     = [module.alb.tg_front_arn, module.alb.tg_back_arn]
  aws_region            = var.aws_region
  ecr_registry          = local.ecr_registry
  db_host               = module.rds.rds_endpoint
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  asg_min               = var.asg_min
  asg_desired           = var.asg_desired
  asg_max               = var.asg_max
  cpu_target_tracking   = var.cpu_target_tracking
  common_tags           = local.common_tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  name_prefix         = local.name_prefix
  aws_region          = var.aws_region
  alert_email         = var.alert_email
  asg_name            = module.compute.asg_name
  rds_identifier      = module.rds.rds_identifier
  alb_arn_suffix      = module.alb.alb_arn_suffix
  tg_front_arn_suffix = module.alb.tg_front_arn_suffix
  tg_back_arn_suffix  = module.alb.tg_back_arn_suffix
}

module "governance" {
  source                = "./modules/governance"
  name_prefix           = local.name_prefix
  account_id            = local.account_id
  backup_role_arn       = var.backup_role_arn
  backup_retention_days = var.db_backup_retention_days
}
