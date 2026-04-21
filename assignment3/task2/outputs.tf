output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "web_server_instance_id" {
  description = "Instance ID of the web server"
  value       = aws_instance.web.id
}

output "db_server_instance_id" {
  description = "Instance ID of the database server"
  value       = aws_instance.db.id
}

output "web_sg_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web_sg.id
}

output "db_sg_id" {
  description = "Database server security group ID"
  value       = aws_security_group.db_sg.id
}