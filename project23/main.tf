data "aws_vpc" "default_project23_0101" {
  default = true
}

data "aws_subnets" "default_project23_0101" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_project23_0101.id]
  }
}

data "aws_ami" "al2023_project23_0101" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# S3 bucket for testing EC2 IAM role access
resource "aws_s3_bucket" "app_bucket_project23_0101" {
  bucket        = "s3-bucket-project23-0101"
  force_destroy = true

  tags = {
    Name = "s3-bucket-project23-0101"
  }
}

# IAM role assumed by EC2
resource "aws_iam_role" "ec2_s3_role_project23_0101" {
  name = "ec2-s3-role-project23-0101"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "ec2-s3-role-project23-0101"
  }
}

# Least-privilege S3 policy scoped to the bucket and its objects
resource "aws_iam_role_policy" "ec2_s3_policy_project23_0101" {
  name = "ec2-s3-policy-project23-0101"
  role = aws_iam_role.ec2_s3_role_project23_0101.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = [
        aws_s3_bucket.app_bucket_project23_0101.arn,
        "${aws_s3_bucket.app_bucket_project23_0101.arn}/*"
      ]
    }]
  })
}

# Allows shell access via AWS Systems Manager Session Manager without opening port 22
resource "aws_iam_role_policy_attachment" "ssm_core_project23_0101" {
  role       = aws_iam_role.ec2_s3_role_project23_0101.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_s3_profile_project23_0101" {
  name = "ec2-s3-profile-project23-0101"
  role = aws_iam_role.ec2_s3_role_project23_0101.name

  tags = {
    Name = "ec2-s3-profile-project23-0101"
  }
}

# Security group with no inbound ports 22 or 3389
resource "aws_security_group" "ec2_s3_sg_project23_0101" {
  name        = "ec2-s3-sg-project23-0101"
  description = "Outbound HTTPS for AWS APIs and S3; no SSH or RDP"
  vpc_id      = data.aws_vpc.default_project23_0101.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-s3-sg-project23-0101"
  }
}

resource "aws_instance" "app_ec2_project23_0101" {
  ami                    = data.aws_ami.al2023_project23_0101.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default_project23_0101.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_s3_sg_project23_0101.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile_project23_0101.name

  tags = {
    Name = "app-ec2-project23-0101"
  }
}
