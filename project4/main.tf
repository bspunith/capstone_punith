resource "aws_iam_user" "user" {
  name = var.user_name

  tags = {
    Name    = var.user_name
    Project = "Project4"
  }
}

resource "aws_iam_user_policy_attachment" "s3_readonly" {
  user       = aws_iam_user.user.name
  policy_arn = var.s3_policy_arn
}
