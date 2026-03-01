# Terraform Backend Bootstrap

This stack bootstraps the remote Terraform backend used by `tf-infra/`.

It creates:

- An S3 bucket for Terraform state (versioned, private, encrypted with KMS)
- A dedicated KMS key for bucket encryption

Usage:

```bash
terraform init
terraform apply
```

After apply, update `tf-infra/backend-config/dev.config` to match the created bucket name/region/profile.
