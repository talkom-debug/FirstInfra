locals {
  common_tags = merge(
    {
      Project     = var.prefix
      Environment = var.environment
      Owner       = var.owner
    },
    var.tags
  )

  ecs_cluster_name       = "${var.prefix}-${var.environment}-cluster"
  ecs_service_name       = "${var.prefix}-${var.environment}-svc"
  ecs_task_family        = "${var.prefix}-${var.environment}-task"
  codebuild_project_name = "${var.prefix}-${var.environment}-${var.build_project_name}"
  codepipeline_name      = "${var.prefix}-${var.environment}-${var.pipeline_name}"
}
