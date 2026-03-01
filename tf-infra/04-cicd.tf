module "pipeline_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket_prefix = "${var.prefix}-${var.environment}-pipeline-"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.common_tags
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [module.ecs.services[local.ecs_service_name].task_exec_iam_role_arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      module.pipeline_bucket.s3_bucket_arn,
      "${module.pipeline_bucket.s3_bucket_arn}/*"
    ]
  }
}

module "codebuild_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.0"

  name        = "${var.prefix}-${var.environment}-codebuild"
  description = "CodeBuild policy for ECS deployments"
  policy      = data.aws_iam_policy_document.codebuild.json

  tags = local.common_tags
}

module "codebuild_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.prefix}-${var.environment}-codebuild"

  trust_policy_permissions = {
    CodeBuildAssume = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["codebuild.amazonaws.com"]
      }]
    }
  }

  policies = {
    CodeBuild = module.codebuild_policy.arn
  }

  tags = local.common_tags
}

module "codebuild_project" {
  source = "../tf-modules/codebuild-project"

  name             = local.codebuild_project_name
  service_role_arn = module.codebuild_role.arn
  buildspec        = "buildspec.yaml"

  environment = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variables = [
      {
        name  = "ECR_REPO"
        value = data.aws_ecr_repository.app.repository_url
      },
      {
        name  = "AWS_REGION"
        value = var.region
      },
      {
        name  = "CLUSTER_NAME"
        value = local.ecs_cluster_name
      },
      {
        name  = "SERVICE_NAME"
        value = local.ecs_service_name
      },
      {
        name  = "TASK_FAMILY"
        value = module.ecs.services[local.ecs_service_name].task_definition_family
      },
      {
        name  = "CONTAINER_NAME"
        value = var.container_name
      }
    ]
  }

  tags = local.common_tags
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      module.pipeline_bucket.s3_bucket_arn,
      "${module.pipeline_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = [module.codebuild_project.project_arn]
  }

  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }
}

module "codepipeline_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.0"

  name        = "${var.prefix}-${var.environment}-codepipeline"
  description = "CodePipeline policy for source and build"
  policy      = data.aws_iam_policy_document.codepipeline.json

  tags = local.common_tags
}

module "codepipeline_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.prefix}-${var.environment}-codepipeline"

  trust_policy_permissions = {
    CodePipelineAssume = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["codepipeline.amazonaws.com"]
      }]
    }
  }

  policies = {
    CodePipeline = module.codepipeline_policy.arn
  }

  tags = local.common_tags
}

module "codepipeline" {
  source = "../tf-modules/codepipeline"

  name     = local.codepipeline_name
  role_arn = module.codepipeline_role.arn

  artifact_store = {
    location = module.pipeline_bucket.s3_bucket_id
    type     = "S3"
  }

  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          output_artifacts = ["SourceOutput"]
          configuration = {
            ConnectionArn    = var.codestar_connection_arn
            FullRepositoryId = "${var.repo_owner}/${var.repo_name}"
            BranchName       = var.repo_branch
            DetectChanges    = "true"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["SourceOutput"]
          output_artifacts = ["BuildOutput"]
          configuration = {
            ProjectName = module.codebuild_project.project_name
          }
        }
      ]
    }
  ]

  tags = local.common_tags
}
