# Modulo governance: CloudTrail multi-region + AWS Backup
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.name_prefix}-cloudtrail-${var.account_id}"
  force_destroy = true
  tags          = { Name = "${var.name_prefix}-cloudtrail" }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid     = "AWSCloudTrailAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [aws_s3_bucket.cloudtrail.arn]
  }
  statement {
    sid     = "AWSCloudTrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]
  tags                          = { Name = "${var.name_prefix}-trail" }
}

resource "aws_backup_vault" "main" {
  name = "${var.name_prefix}-vault"
  tags = { Name = "${var.name_prefix}-vault" }
}

resource "aws_backup_plan" "main" {
  name = "${var.name_prefix}-backup-plan"
  rule {
    rule_name         = "DiarioTecnoHome"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)"
    start_window      = 60
    completion_window = 120
    lifecycle {
      delete_after = var.backup_retention_days
    }
  }
  tags = { Name = "${var.name_prefix}-backup-plan" }
}

resource "aws_backup_selection" "main" {
  name         = "${var.name_prefix}-seleccion"
  iam_role_arn = var.backup_role_arn != "" ? var.backup_role_arn : "arn:aws:iam::${var.account_id}:role/LabRole"
  plan_id      = aws_backup_plan.main.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Proyecto"
    value = "TecnoHome-Infraestructura"
  }
}
