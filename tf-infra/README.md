# Application Infrastructure

This stack defines the application infrastructure using Terraform Registry modules.

High level:

- VPC (2 AZs)
- ALB (public)
- ECS Fargate service (private)
- VPC endpoints for ECR/Logs/S3
- CI/CD (CodePipeline + CodeBuild)

Workflow:

```bash
terraform init -backend-config=backend-config/dev.config
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```
