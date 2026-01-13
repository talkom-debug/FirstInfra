# FirstInfra

Terraform automation for a highly-available VPC, ALB, and ECS Fargate service pulling a private image from ECR over private endpoints.

## What this creates
- VPC with 2 public and 2 private subnets across 2 AZs
- Internet-facing ALB (public subnets) and ECS tasks (private subnets)
- Security groups for ALB, ECS tasks, and interface endpoints
- ECR repository referenced via data source (bring-your-own repository)
- VPC endpoints for ECR API/DKR, CloudWatch Logs, and S3 gateway
- ECS cluster, task definition, and service (desired count 2)

## Prereqs
- Terraform >= 1.4
- AWS CLI and Docker (for image build/push)
- An existing private, encrypted ECR repository

## Image build & push
1) Build and tag:
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
   docker build -t <repo-name>:latest ./docker
   docker tag <repo-name>:latest <account>.dkr.ecr.<region>.amazonaws.com/<repo-name>:latest
   docker push <account>.dkr.ecr.<region>.amazonaws.com/<repo-name>:latest
   ```

## Terraform usage
1) Create `terraform.tfvars` and set your values (example below).
2) Run:
   ```bash
   terraform init
   terraform apply
   ```

Example `terraform.tfvars`:
```hcl
region               = "us-east-1"
azs                  = ["us-east-1a", "us-east-1b"]
name_prefix          = "firstinfra"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
ecr_repository_name  = "hello-world"
image_tag            = "latest"
```
