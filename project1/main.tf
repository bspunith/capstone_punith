# Default VPC

data "aws_vpc" "default" {
  default = true
}

# Latest Ubuntu AMI

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group

resource "aws_security_group" "web_sg_0101" {

  name        = "web-sg-0101"
  description = "HTTP access for Project 1"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
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
    Name = "web-sg-0101"
  }
}

# Web Server EC2 Instance

resource "aws_instance" "webserver_0101" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.web_sg_0101.id
  ]

  user_data = <<-EOF
#!/bin/bash

apt update -y
apt install apache2 -y

echo "<h1>Terraform Web Server 0101</h1>" > /var/www/html/index.html

systemctl enable apache2
systemctl start apache2
EOF

  tags = {
    Name = "webserver-0101"
  }
}
