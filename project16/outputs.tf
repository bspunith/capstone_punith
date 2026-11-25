output "https_url" {
  value = "https://${aws_lb.project16_alb.dns_name}"
}

output "alb_dns_name" {
  value = aws_lb.project16_alb.dns_name
}
