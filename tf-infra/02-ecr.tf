module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  count = var.create_ecr_repository ? 1 : 0

  repository_name                 = var.ecr_repository_name
  repository_image_tag_mutability = "MUTABLE"
  repository_force_delete         = var.ecr_repository_force_delete

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.common_tags
}
