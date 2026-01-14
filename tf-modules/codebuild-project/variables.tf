variable "name" {
  description = "CodeBuild project name"
  type        = string
}

variable "service_role_arn" {
  description = "IAM role ARN for CodeBuild"
  type        = string
}

variable "buildspec" {
  description = "Buildspec file path"
  type        = string
  default     = "buildspec.yaml"
}

variable "environment" {
  description = "CodeBuild environment configuration"
  type = object({
    compute_type    = string
    image           = string
    type            = string
    privileged_mode = bool
    environment_variables = list(object({
      name  = string
      value = string
      type  = optional(string, "PLAINTEXT")
    }))
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
