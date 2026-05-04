output "public_instance_ip" {
  value = aws_instance.web_public.public_ip
}

output "public_instance_id" {
  value = aws_instance.web_public.id
}

output "private_instance_id" {
  value = aws_instance.db_private.id
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "private_key_pem" {
  value     = tls_private_key.main.private_key_pem
  sensitive = true
}
