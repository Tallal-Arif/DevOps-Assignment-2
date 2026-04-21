 
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "iam_role_arn" {
  description = "ARN of the EC2 S3 access role"
  value       = aws_iam_role.ec2_s3_role.arn
}