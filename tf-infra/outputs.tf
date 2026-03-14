output "alb_dns_name" {
  description = "ALB public DNS name"
  value       = module.alb.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = data.aws_ecr_repository.app.repository_url
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = try(module.codebuild_project[0].project_name, null)
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = try(module.codepipeline[0].pipeline_name, null)
}
