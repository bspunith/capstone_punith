output "instance_id" {
  value = aws_instance.monitoring_server_0101.id
}

output "public_ip" {
  value = aws_instance.monitoring_server_0101.public_ip
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.cpu_alarm_0101.alarm_name
}
