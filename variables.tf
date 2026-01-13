variable "region" {
  type        = string
  description = "AWS region"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  validation {
    condition     = length(var.azs) == 2
    error_message = "Exactly two AZs are required."
  }
}

variable "name_prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDRs are required."
  }
}

variable "ecr_repository_name" {
  type        = string
  description = "Existing ECR repository name"
}

variable "image_tag" {
  type        = string
  description = "ECR image tag to deploy"
  default     = "latest"
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 80
}

variable "desired_count" {
  type        = number
  description = "ECS service desired count"
  default     = 2
}

variable "task_cpu" {
  type        = number
  description = "Fargate task CPU units"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Fargate task memory (MB)"
  default     = 512
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention"
  default     = 7
}

variable "repo_owner" {
  type        = string
  description = "Source repository owner (e.g. GitHub org/user)"
}

variable "repo_name" {
  type        = string
  description = "Source repository name"
}

variable "repo_branch" {
  type        = string
  description = "Source repository branch"
  default     = "main"
}

variable "codestar_connection_arn" {
  type        = string
  description = "Existing CodeStar Connection ARN for the repo"
}

variable "pipeline_name" {
  type        = string
  description = "CodePipeline name"
  default     = "firstinfra-pipeline"
}

variable "build_project_name" {
  type        = string
  description = "CodeBuild project name"
  default     = "firstinfra-build"
}

variable "container_name" {
  type        = string
  description = "Container name in task definition to update"
  default     = "app"
}
