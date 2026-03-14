variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "owner" {
  description = "Owner tag value"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use (optional)"
  type        = string
  default     = null
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  validation {
    condition     = length(var.azs) == 2
    error_message = "Exactly two AZs are required."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDRs are required."
  }
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecr_repository_name" {
  description = "Existing ECR repository name"
  type        = string
}

variable "create_ecs_resources" {
  description = "Whether to create ECS/Fargate resources"
  type        = bool
  default     = true
}

variable "image_tag" {
  description = "ECR image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "container_name" {
  description = "Container name in task definition to update"
  type        = string
  default     = "app"
}

variable "desired_count" {
  description = "ECS service desired count"
  type        = number
  default     = 2
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory (MB)"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "repo_owner" {
  description = "Source repository owner (e.g. GitHub org/user)"
  type        = string
}

variable "repo_name" {
  description = "Source repository name"
  type        = string
}

variable "repo_branch" {
  description = "Source repository branch"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "Existing CodeStar Connection ARN for the repo"
  type        = string
}

variable "create_cicd_resources" {
  description = "Whether to create CodeBuild/CodePipeline resources"
  type        = bool
  default     = true

  validation {
    condition     = !var.create_cicd_resources || var.create_ecs_resources
    error_message = "create_cicd_resources can be true only when create_ecs_resources is also true."
  }
}

variable "pipeline_name" {
  description = "CodePipeline name"
  type        = string
  default     = "firstinfra-pipeline"
}

variable "build_project_name" {
  description = "CodeBuild project name"
  type        = string
  default     = "firstinfra-build"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
