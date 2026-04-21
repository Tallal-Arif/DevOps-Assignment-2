terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Get the VPC and subnets we created in Task 1
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

data "aws_subnet" "public_1" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-1"]
  }
}

data "aws_subnet" "private_1" {
  filter {
    name   = "tag:Name"
    values = ["private-subnet-1"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Security group for public web server"
  vpc_id      = data.aws_vpc.main.id
  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["103.26.81.43/32"]
   }
   egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
    Name = "web-server-sg"
  }
}


resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for datqabase server"
  vpc_id      = data.aws_vpc.main.id

 
  ingress{
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "db_sg"
    }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "mykey"
  public_key = file("mykey.pub")
}

# Public EC2 Instance - Web Server
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              echo "<html><body><h1>Web Server</h1><p>Instance ID: $INSTANCE_ID</p></body></html>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "web-server"
  }
}

# Private EC2 Instance - Database Server
resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "db-server"
  }
}