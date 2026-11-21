output "iam_user_name" {
  description = "IAM User Name"
  value       = aws_iam_user.user.name
}

output "attached_policy" {
  description = "Attached S3 Read Only Policy"
  value       = var.s3_policy_arn
}

