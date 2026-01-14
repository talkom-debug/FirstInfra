variable "name" {
  description = "CodePipeline name"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN for CodePipeline"
  type        = string
}

variable "artifact_store" {
  description = "Artifact store configuration"
  type = object({
    location = string
    type     = string
  })
}

variable "stages" {
  description = "Pipeline stages and actions"
  type = list(object({
    name = string
    actions = list(object({
      name             = string
      category         = string
      owner            = string
      provider         = string
      version          = string
      input_artifacts  = optional(list(string), [])
      output_artifacts = optional(list(string), [])
      configuration    = map(string)
    }))
  }))
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
