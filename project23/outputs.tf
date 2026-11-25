output "instance_id_project23_0101" {
  value = aws_instance.app_ec2_project23_0101.id
}

output "s3_bucket_name_project23_0101" {
  value = aws_s3_bucket.app_bucket_project23_0101.bucket
}

output "iam_role_name_project23_0101" {
  value = aws_iam_role.ec2_s3_role_project23_0101.name
}
