########################
# Default VPC
########################

data "aws_vpc" "default" {
  default = true
}

########################
# Fixed Subnets
########################

locals {
  alb_subnets = [
    "subnet-02a246541c0a65ad4",
    "subnet-0391feeb69966b00f"
  ]

  ec2_subnet = "subnet-02a246541c0a65ad4"
}

########################
# ALB Security Group
########################

resource "aws_security_group" "alb_sg" {
  name        = "project16-alb-sg-0101"
  description = "HTTPS only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "project16-alb-sg-0101"
  }
}

########################
# Web Security Group
########################

resource "aws_security_group" "web_sg" {
  name        = "project16-web-sg-0101"
  description = "Allow ALB only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project16-web-sg-0101"
  }
}

########################
# Latest Amazon Linux 2023
########################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

########################
# Web Server
########################

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = local.ec2_subnet

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data = <<-EOF
#!/bin/bash

dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<HTML
<html>
<head>
<title>Project16 HTTPS</title>
</head>
<body>
<h1>Project 16 HTTPS Enabled</h1>
<p>Project16-0101</p>
<p>HTTPS provided by ALB and ACM</p>
</body>
</html>
HTML
EOF

  tags = {
    Name = "project16-web-0101"
  }
}

########################
# ACM Imported Certificate
########################

resource "aws_acm_certificate" "project16_cert" {
  private_key      = file("${path.module}/server.key")
  certificate_body = file("${path.module}/server.crt")

  tags = {
    Name = "project16-cert-0101"
  }
}

########################
# Target Group
########################

resource "aws_lb_target_group" "web_tg" {
  name     = "project16-tg-0101"
  port     = 80
  protocol = "HTTP"

  vpc_id = data.aws_vpc.default.id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    Name = "project16-tg-0101"
  }
}

resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

########################
# Application Load Balancer
########################

resource "aws_lb" "project16_alb" {
  name               = "project16-alb-0101"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = local.alb_subnets

  tags = {
    Name = "project16-alb-0101"
  }
}

########################
# HTTPS Listener
########################

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.project16_alb.arn

  port     = 443
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.project16_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
