
# 🧭 Agent Instruction: Terraform MCP (CloudZone Enhanced Standards)

## 1️⃣ General Rules
- Scaffold Terraform infrastructure as code following **CloudZone's best practices**.
- Always use **official AWS modules** from the Terraform Registry (`terraform-aws-modules/<service>/aws`) when available.  
- If no official module exists:
  - Create a **local module** under `tf-modules/<module-name>/`
  - Each module must contain:
    ```
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    README.md (optional but recommended)
    ```
- Do not Create an individual resources, you must use modules only.
- locals should be in locals.tf and not in the other files.
- Reference all modules from the **`tf-infra/`** folder.  
- Maintain the exact folder structure (below).
- At the end of the task run terraform validate and fix all the issues if exists.

---

## 2️⃣ Folder Layout
```
.
├── tf-infra
│   ├── providers.tf
│   ├── backend.tf
│   ├── versions.tf
│   ├── locals.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── 01-networking.tf
│   ├── 02-<resource-name-1>.tf
│   ├── 03-<resource-name-N>.tf
│   ├── data.tf
│   ├── dev.tfvars
│   └── backend-config/
│       └── dev.config
└── tf-modules
    └── <module-name>/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── versions.tf
        └── README.md
```

💡 **Tip:** Numbered filenames (e.g., `01-networking.tf`, `02-security.tf`) ensure consistent load order and readability.

---

## 3️⃣ Module Authoring Conventions

### 🚫 Do Not Create Local Modules for Official AWS Services

If an official AWS module exists in the Terraform Registry under  
`terraform-aws-modules/<service>/aws`, **use it** — never recreate it locally.  

Create a local module under `tf-modules/` **only if:**
- No official module exists, **or**
- You need to extend the official one (wrap, don’t re-implement).

**Never create local modules for:**
- `terraform-aws-acm`
- `terraform-aws-alb`
- `terraform-aws-apigateway-v2`
- `terraform-aws-app-runner`
- `terraform-aws-appconfig`
- `terraform-aws-appsync`
- `terraform-aws-atlantis`
- `terraform-aws-autoscaling`
- `terraform-aws-batch`
- `terraform-aws-cloudfront`
- `terraform-aws-cloudwatch`
- `terraform-aws-customer-gateway`
- `terraform-aws-datadog-forwarders`
- `terraform-aws-dms`
- `terraform-aws-dynamodb-table`
- `terraform-aws-ebs-optimized`
- `terraform-aws-ec2-instance`
- `terraform-aws-ecr`
- `terraform-aws-ecs`
- `terraform-aws-efs`
- `terraform-aws-eks`
- `terraform-aws-eks-pod-identity`
- `terraform-aws-elasticache`
- `terraform-aws-elb`
- `terraform-aws-emr`
- `terraform-aws-eventbridge`
- `terraform-aws-fsx`
- `terraform-aws-global-accelerator`
- `terraform-aws-iam`
- `terraform-aws-key-pair`
- `terraform-aws-kms`
- `terraform-aws-lambda`
- `terraform-aws-managed-service-grafana`
- `terraform-aws-managed-service-prometheus`
- `terraform-aws-memory-db`
- `terraform-aws-msk-kafka-cluster`
- `terraform-aws-network-firewall`
- `terraform-aws-notify-slack`
- `terraform-aws-opensearch`
- `terraform-aws-pricing`
- `terraform-aws-rds`
- `terraform-aws-rds-aurora`
- `terraform-aws-rds-proxy`
- `terraform-aws-redshift`
- `terraform-aws-route53`
- `terraform-aws-s3-bucket`
- `terraform-aws-s3-object`
- `terraform-aws-secrets-manager`
- `terraform-aws-security-group`
- `terraform-aws-sns`
- `terraform-aws-solutions`
- `terraform-aws-sqs`
- `terraform-aws-ssm-parameter`
- `terraform-aws-step-functions`
- `terraform-aws-transit-gateway`
- `terraform-aws-vpc`
- `terraform-aws-vpn-gateway`
- `terraform-provider-http`

When detected, the agent must **use the official module** instead of scaffolding a new one.

---

### ✅ Variable Declaration Standard
Every variable must:
- Have a **description**
- Include a **default** if optional
- Have an explicit **type**

Example:
```hcl
variable "prefix" {
  description = "The prefix for resource names"
  type        = string
}

variable "availability_zones" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}
```

💡 *Never leave a variable without a description.*

---

### ✅ outputs.tf Example
```hcl
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.this.id
}
```

---

### ✅ versions.tf Example
```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

### ✅ Dynamic Local Module Example
When multiple resources are repeated, **never create individual resource blocks**.  
Instead, create **one dynamic local module** and call it using `for_each`.

#### Example local module (`tf-modules/ses-domain`)
`main.tf`
```hcl
resource "aws_ses_domain_identity" "this" {
  domain = var.domain
  tags   = var.tags
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}
```

`variables.tf`
```hcl
variable "domain" {
  description = "The domain to configure for SES"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

`outputs.tf`
```hcl
output "identity_arn" {
  description = "SES Domain Identity ARN"
  value       = aws_ses_domain_identity.this.arn
}
```

---

### ✅ Example Module Invocation (Dynamic)
In `tf-infra/40-ses.tf`:
```hcl
locals {
  ses_domains = toset([
    "example.com",
    "api.example.com",
  ])
}

module "ses_domain" {
  source = "../tf-modules/ses-domain"

  for_each = local.ses_domains
  domain   = each.key
  tags     = local.common_tags
}

output "ses_domain_arns" {
  description = "Map of SES domain ARNs"
  value       = { for k, m in module.ses_domain : k => m.identity_arn }
}
```

💡 *This pattern ensures reusability, avoids duplication, and aligns with CloudZone’s IaC philosophy.*

---

## 4️⃣ Environment & State Layout
Each environment (e.g., `dev`, `staging`, `prod`) must have:
- A unique backend config (`backend-config/dev.config`)
- A dedicated tfvars file (`dev.tfvars`)
- Dynamic modules referencing `var.environment`

Example call:
```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.prefix}-${var.environment}-app"
  acl    = "private"

  tags = merge(local.common_tags, {
    Environment = var.environment
  })
}
```

---

## 5️⃣ Dynamic & Environment-Driven Design
- All Terraform components must support `var.environment` (e.g., `dev`, `staging`, `prod`).
- Global variables (`prefix`, `region`, `tags`) must be defined in `variables.tf`.
- Avoid hardcoded names and environment logic inside modules.
- Use locals for reusable expressions.

Example `locals.tf`:
```hcl
locals {
  common_tags = {
    Project     = var.prefix
    Environment = var.environment
    Owner       = var.owner
  }
}
```

---

## 6️⃣ Registry Usage
When using Terraform Registry modules:
- Only use modules under: `terraform-aws-modules/*/aws`
- Always pin versions:
  ```hcl
  version = "~> X.Y"
  ```
- If no official module exists → create one under `tf-modules/`.

---

## 7️⃣ Enforced Best Practices
- Run `terraform fmt -recursive` before every commit.  
- Run `terraform validate` on every module and environment.  
- Never hardcode resource names — always use `prefix` and `environment`.  
- Tag everything:
  ```hcl
  tags = merge(local.common_tags, {
    Environment = var.environment
  })
  ```
- Use numbered filenames (00, 01, 02…) in `tf-infra` for readability.
- Use `for_each` for repeated resources instead of copy-paste.
- Avoid inline environment-specific logic.
- Ensure every resource, module, and output has a meaningful description.

---

## 8️⃣ Pre-Commit Hooks (Recommended)
`.pre-commit-config.yaml`
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.91.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
```

Run once:
```bash
pre-commit install
```

---

## 9️⃣ Terraform CLI Workflow
```bash
cd tf-infra

# Initialize with environment backend
terraform init -backend-config=backend-config/dev.config

# Validate configuration
terraform validate

# Plan and apply using env vars
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

---

## ✅ Summary of Key CloudZone Standards
| Principle | Description |
|------------|--------------|
| **Official Modules First** | Always use `terraform-aws-modules/*/aws` where available |
| **Dynamic Local Modules** | Group repeatable logic under `tf-modules/` and use `for_each` |
| **Numbered Files** | Enforce order and readability under `tf-infra/` |
| **Environment Isolation** | Separate backend + tfvars per environment |
| **No Hardcoding** | Use `${var.prefix}-${var.environment}` everywhere |
| **Tagging Standard** | Always include `Project`, `Environment`, and `Owner` |
| **Version Pinning** | Use `version = "~> X.Y"` for registry modules |
| **Validation & Formatting** | Enforce `terraform fmt` and `terraform validate` pre-commit |

---

> 🧩 **This document defines the CloudZone Terraform MCP standards for infrastructure-as-code automation.**  
> It enforces structure, consistency, and maintainability across all Terraform-based projects.
