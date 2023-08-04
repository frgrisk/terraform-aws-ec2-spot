output "private_ip" {
  value = aws_spot_instance_request.instance.private_ip
}

output "hostname" {
  value = var.hostname
}

output "instance_id" {
  value = aws_spot_instance_request.instance.spot_instance_id
}
