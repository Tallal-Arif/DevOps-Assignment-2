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

# The existing ALB and SG from Assignment 3 would typically be imported or 
# managed here. For simplicity we mock the reference to existing resources.

resource "aws_lb_target_group" "blue" {
  name     = "app-tg-blue"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_target_group" "green" {
  name     = "app-tg-green"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_autoscaling_group" "blue" {
  name                = "app-asg-blue"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.blue.arn]
  
  # Requires a launch template configuration pointing to the ECR image
  # (Placeholder for launch template logic)
}

resource "aws_autoscaling_group" "green" {
  name                = "app-asg-green"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.green.arn]

  # Requires a launch template configuration pointing to the ECR image
  # (Placeholder for launch template logic)
}

# The active listener rule points to blue or green based on current deployment state
# This would be updated dynamically by Jenkins using AWS CLI
