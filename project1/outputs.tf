output "instance_id" {
  value = aws_instance.webserver_0101.id
}

output "public_ip" {
  value = aws_instance.webserver_0101.public_ip
}

output "instance_name" {
  value = "webserver-0101"
}
