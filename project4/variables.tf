variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "user_name" {
  description = "IAM Username"
  type        = string
}

variable "s3_policy_arn" {
  description = "S3 Read Only Policy ARN"
  type        = string
}
