variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access (e.g., 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0" # Defaulting to all for demo, user should ideally restrict
}
