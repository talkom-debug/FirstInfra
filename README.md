# FirstInfra

Terraform infrastructure split into two stacks:

- `backend/`: bootstraps the remote state backend (S3 state bucket + optional locking)
- `tf-infra/`: the actual application infrastructure (VPC, ALB, ECS Fargate, CI/CD)

`legacy/root-terraform/` contains an older, resource-based Terraform config kept for reference. Use `tf-infra/` going forward.

## Prereqs

- Terraform >= 1.6
- AWS CLI
- An existing ECR repository (this config references the repo via a data source)

## Bootstrap Backend (one-time)

```bash
cd backend
terraform init
terraform apply
```

## Provision / Destroy Infrastructure

```bash
cd tf-infra
terraform init -backend-config=backend-config/dev.config
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

# destroy
terraform destroy -var-file=dev.tfvars
```

## Image Build & Push

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
docker build -t <repo-name>:latest ./docker
docker tag <repo-name>:latest <account>.dkr.ecr.<region>.amazonaws.com/<repo-name>:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/<repo-name>:latest
```
