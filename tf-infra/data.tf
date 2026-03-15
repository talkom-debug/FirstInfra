data "aws_ecr_repository" "app" {
  count = (!var.create_ecr_repository && (var.create_ecs_resources || var.create_cicd_resources)) ? 1 : 0

  name = var.ecr_repository_name
}
