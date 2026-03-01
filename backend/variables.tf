variable "region" {
  description = "AWS region to operate in"
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "firstinfra"
}

variable "env_name" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag value"
  type        = string
  default     = "platform"
}

variable "aws_profile" {
  description = "AWS CLI profile to use (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
