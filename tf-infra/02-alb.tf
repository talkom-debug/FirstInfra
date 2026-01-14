module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = "${var.prefix}-${var.environment}-alb"
  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  create_security_group = false
  security_group_ids    = [module.sg_alb.security_group_id]

  listeners = {
    http = {
      port     = var.container_port
      protocol = "HTTP"
      forward = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      name        = "${var.prefix}-${var.environment}-tg"
      protocol    = "HTTP"
      port        = var.container_port
      target_type = "ip"
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        interval            = 10
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-399"
      }
    }
  }

  tags = local.common_tags
}
