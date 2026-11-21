# Default VPC

data "aws_vpc" "default" {
  default = true
}

# Latest Ubuntu 22.04 AMI

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group

resource "aws_security_group" "monitoring_sg_0101" {

  name        = "monitoring-sg-0101"
  description = "CloudWatch Monitoring Project"
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
    Name = "monitoring-sg-0101"
  }
}

# EC2 Instance

resource "aws_instance" "monitoring_server_0101" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.monitoring_sg_0101.id
  ]

  user_data = <<-EOF
#!/bin/bash

apt update -y
apt install apache2 stress -y

echo "<h1>CloudWatch Monitoring Server 0101</h1>" > /var/www/html/index.html

systemctl enable apache2
systemctl start apache2

# Generate CPU load automatically
stress --cpu 2 --timeout 600 &
EOF

  tags = {
    Name = "monitoring-server-0101"
  }
}

# CloudWatch Alarm

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_0101" {

  alarm_name          = "HighCPUAlarm-0101"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 60
  statistic = "Average"

  threshold = 60

  alarm_description = "CPU exceeds 60 percent"

  dimensions = {
    InstanceId = aws_instance.monitoring_server_0101.id
  }

  treat_missing_data = "notBreaching"
}
