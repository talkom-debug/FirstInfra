resource "aws_codepipeline" "this" {
  name     = var.name
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_store.location
    type     = var.artifact_store.type
  }

  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name             = action.value.name
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          input_artifacts  = action.value.input_artifacts
          output_artifacts = action.value.output_artifacts
          configuration    = action.value.configuration
        }
      }
    }
  }

  tags = var.tags
}
