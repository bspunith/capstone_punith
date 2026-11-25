terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default_0101" {
  default = true
}

data "aws_ami" "al2023_0101" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  # One subnet in ap-south-1a and one subnet in ap-south-1b
  subnet_ids_0101 = [
    "subnet-02a246541c0a65ad4",
    "subnet-0391feeb69966b00f",
  ]
}

# Security group for ALB: HTTP (80) only; no port 22 or 3389
resource "aws_security_group" "alb_sg_0101" {
  name        = "alb-sg-0101"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = data.aws_vpc.default_0101.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-0101"
  }
}

# Security group for EC2s: HTTP (80) from ALB SG only; no port 22 or 3389
resource "aws_security_group" "ec2_sg_0101" {
  name        = "ec2-sg-0101"
  description = "Allow HTTP from ALB only"
  vpc_id      = data.aws_vpc.default_0101.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg_0101.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-0101"
  }
}

# 2 EC2 instances in different AZ subnets
resource "aws_instance" "app_ec2_0101" {
  count                  = 2
  ami                    = data.aws_ami.al2023_0101.id
  instance_type          = "t3.micro"
  subnet_id              = local.subnet_ids_0101[count.index]
  vpc_security_group_ids = [aws_security_group.ec2_sg_0101.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable --now nginx
              echo "<h1>Response from app-ec2-${count.index + 1}-0101 ($(hostname -f))</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "app-ec2-${count.index + 1}-0101"
  }
}

# Target Group with ALB health check on /
resource "aws_lb_target_group" "app_tg_0101" {
  name     = "app-tg-0101"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_0101.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = {
    Name = "app-tg-0101"
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attach_0101" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_tg_0101.arn
  target_id        = aws_instance.app_ec2_0101[count.index].id
  port             = 80
}

# Application Load Balancer across different AZ subnets
resource "aws_lb" "app_alb_0101" {
  name               = "app-alb-0101"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_0101.id]
  subnets            = local.subnet_ids_0101

  tags = {
    Name = "app-alb-0101"
  }
}

resource "aws_lb_listener" "http_0101" {
  load_balancer_arn = aws_lb.app_alb_0101.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg_0101.arn
  }
}

output "alb_dns_name_0101" {
  value = aws_lb.app_alb_0101.dns_name
}
