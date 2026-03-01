# Legacy Root Terraform (Do Not Use)

This directory contains the original single-stack Terraform configuration that managed AWS resources directly with individual `aws_*` resources.

The repository has been refactored to use the CloudZone layout and module-first approach:

- `backend/` bootstraps remote state
- `tf-infra/` defines the infrastructure using modules

Keep this folder only as historical reference.
