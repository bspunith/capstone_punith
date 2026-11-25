data "aws_vpc" "default_project24_0101" {
  default = true
}

data "aws_subnets" "default_project24_0101" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_project24_0101.id]
  }
}

data "aws_ami" "al2023_project24_0101" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# IAM role so you can connect via Session Manager without opening port 22
resource "aws_iam_role" "ec2_chaos_role_project24_0101" {
  name = "ec2-chaos-role-project24-0101"

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
    Name = "ec2-chaos-role-project24-0101"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core_project24_0101" {
  role       = aws_iam_role.ec2_chaos_role_project24_0101.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_chaos_profile_project24_0101" {
  name = "ec2-chaos-profile-project24-0101"
  role = aws_iam_role.ec2_chaos_role_project24_0101.name

  tags = {
    Name = "ec2-chaos-profile-project24-0101"
  }
}

# Security group with no inbound ports 22 or 3389
resource "aws_security_group" "ec2_chaos_sg_project24_0101" {
  name        = "ec2-chaos-sg-project24-0101"
  description = "Outbound access for SSM/updates; no SSH or RDP"
  vpc_id      = data.aws_vpc.default_project24_0101.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-chaos-sg-project24-0101"
  }
}

resource "aws_instance" "app_ec2_project24_0101" {
  ami                    = data.aws_ami.al2023_project24_0101.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default_project24_0101.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_chaos_sg_project24_0101.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_chaos_profile_project24_0101.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable --now nginx
              echo "OK - app-ec2-project24-0101" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "app-ec2-project24-0101"
  }
}
