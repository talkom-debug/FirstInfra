resource "aws_codebuild_project" "this" {
  name         = var.name
  service_role = var.service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.environment.compute_type
    image           = var.environment.image
    type            = var.environment.type
    privileged_mode = var.environment.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  tags = var.tags
}
