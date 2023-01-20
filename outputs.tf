output "private_ip" {
  value = aws_spot_instance_request.instance.private_ip
}

output "hostname" {
  value = var.hostname
}
