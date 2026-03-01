module "ecs_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 5.0"

  name              = "/ecs/${var.prefix}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name = local.ecs_cluster_name

  services = {
    (local.ecs_service_name) = {
      name   = local.ecs_service_name
      family = local.ecs_task_family

      cpu    = var.task_cpu
      memory = var.task_memory

      desired_count = var.desired_count
      launch_type   = "FARGATE"

      create_task_exec_iam_role = true
      task_exec_iam_role_name   = "${local.ecs_task_family}-exec"

      subnet_ids         = module.vpc.private_subnets
      security_group_ids = [module.sg_ecs.security_group_id]
      assign_public_ip   = false

      container_definitions = {
        app = {
          image = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
          port_mappings = [
            {
              containerPort = var.container_port
              protocol      = "tcp"
            }
          ]
          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.ecs_log_group.cloudwatch_log_group_name
              awslogs-region        = var.region
              awslogs-stream-prefix = "app"
            }
          }
          essential = true
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["app"].arn
          container_name   = var.container_name
          container_port   = var.container_port
        }
      }
    }
  }

  tags = local.common_tags
}
