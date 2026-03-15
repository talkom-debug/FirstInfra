# Application Infrastructure

This stack defines the application infrastructure using Terraform Registry modules.

High level:

- VPC (2 AZs)
- ALB (public)
- ECR repository (optional)
- ECS Fargate service (private, optional)
- VPC endpoints for ECR/Logs/S3
- CI/CD (CodePipeline + CodeBuild, optional)

Workflow:

```bash
terraform init -backend-config=backend-config/dev.config
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Optional flags in `dev.tfvars`:

- `create_ecr_repository = false` skips creating the ECR repository and instead reads an existing repo by name
- `create_ecs_resources = false` skips the ECS cluster, service, task definition, task execution role, and log group
- `create_cicd_resources = false` skips the pipeline artifact bucket, CodeBuild, CodePipeline, and their IAM roles/policies

`create_cicd_resources` can be `true` only when `create_ecs_resources` is also `true`.

When both flags are `false`, the stack does not need an existing ECR repository or CI/CD repository connection values.
