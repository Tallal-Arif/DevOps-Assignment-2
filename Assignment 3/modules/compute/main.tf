# Key Pair
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh
}

# IAM Role for S3 Access (Task 3)
resource "aws_iam_role" "s3_access_role" {
  name = "${var.environment}-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.environment}-s3-access-policy"
  description = "Allow EC2 to read/write to specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "s3_profile" {
  name = "${var.environment}-s3-profile"
  role = aws_iam_role.s3_access_role.name
}

# Public EC2 Instance (Task 2)
resource "aws_instance" "web_public" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.web_sg_id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.s3_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<h1>Public Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name        = "${var.environment}-public-web"
    Environment = var.environment
  }
}

# Private EC2 Instance (Task 2)
resource "aws_instance" "db_private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = aws_key_pair.main.key_name

  tags = {
    Name        = "${var.environment}-private-db"
    Environment = var.environment
  }
}

# --- Auto Scaling Group (Task 4) ---

resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.environment}-web-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.web_sg_id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.s3_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx stress-ng
              echo "<h1>ASG Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-asg-instance"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.environment}-web-asg"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  default_cooldown = 30 
  
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg-instance"
    propagate_at_launch = true
  }
}

# SNS Topic for Scaling Notifications
resource "aws_sns_topic" "scaling_notifications" {
  name = "${var.environment}-scaling-notifications"

  tags = {
    Name        = "${var.environment}-scaling-notifications"
    Environment = var.environment
  }
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "scaling_email" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.scaling_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.environment}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.environment}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_description = "Scale out if CPU > 60% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.environment}-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_description = "Scale in if CPU < 20% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}

