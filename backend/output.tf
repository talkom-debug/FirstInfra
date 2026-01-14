output "s3_bucket_name" {
  description = "Terraform state bucket name"
  value       = module.s3_terraform.s3_bucket_id
}
output "dynamodb_name" {
  description = "Terraform DynamoDB table name"
  value       = aws_dynamodb_table.terraform_statelock.name
}
