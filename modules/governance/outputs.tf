output "cloudtrail_bucket" { value = aws_s3_bucket.cloudtrail.bucket }
output "backup_vault" { value = aws_backup_vault.main.name }
