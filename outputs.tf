
output "app_url" {
  description = "URL publica de la aplicacion (DNS del ALB)"
  value       = "http://${module.alb.alb_dns_name}"
}
output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
output "ecr_frontend_url" {
  value = module.ecr.frontend_repository_url
}
output "ecr_backend_url" {
  value = module.ecr.backend_repository_url
}
output "asg_name" {
  value = module.compute.asg_name
}
output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}
output "cloudtrail_bucket" {
  value = module.governance.cloudtrail_bucket
}
