output "s3_bucket_name" {
  description = "Terraform state bucket name"
  value       = module.s3_terraform.s3_bucket_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for bucket encryption"
  value       = module.kms_terraform_state.key_arn
}
