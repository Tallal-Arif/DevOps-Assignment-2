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

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-assignment-3-bce35194"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "jenkins_controller_sg" {
  name        = "jenkins-controller-sg"
  description = "Security group for Jenkins Controller"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Should be restricted to your IP in a real scenario
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Should be restricted to your IP in a real scenario
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-controller-sg"
  }
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins-agent-sg"
  description = "Security group for Jenkins Agent"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description     = "SSH from Controller"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_controller_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-agent-sg"
  }
}

resource "aws_instance" "jenkins_controller" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.jenkins_controller_sg.id]
  user_data              = file("${path.module}/user_data.sh")
  key_name               = "dev-key" # Assuming dev-key from Assignment 3

  tags = {
    Name = "jenkins-controller"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  key_name               = "dev-key"

  tags = {
    Name = "jenkins-agent"
  }
}

output "jenkins_controller_public_ip" {
  value = aws_instance.jenkins_controller.public_ip
}

output "jenkins_agent_private_ip" {
  value = aws_instance.jenkins_agent.private_ip
}
