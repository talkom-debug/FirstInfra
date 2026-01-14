module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.prefix}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway = false
  single_nat_gateway = false
  create_igw         = true

  tags = local.common_tags
}

module "sg_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.prefix}-${var.environment}-alb-sg"
  description = "ALB ingress from the Internet"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      description = "App ingress"
      cidr_blocks = join(",", var.alb_ingress_cidrs)
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}

module "sg_ecs" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.prefix}-${var.environment}-ecs-sg"
  description = "ECS tasks allow ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "ALB ingress"
      source_security_group_id = module.sg_alb.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}

module "sg_endpoints" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.prefix}-${var.environment}-endpoints-sg"
  description = "Interface endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "VPC HTTPS"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.sg_endpoints.security_group_id]
  subnet_ids         = module.vpc.private_subnets

  endpoints = {
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      tags = merge(local.common_tags, {
        Name = "${var.prefix}-${var.environment}-ecr-api"
      })
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      tags = merge(local.common_tags, {
        Name = "${var.prefix}-${var.environment}-ecr-dkr"
      })
    }
    logs = {
      service             = "logs"
      private_dns_enabled = true
      tags = merge(local.common_tags, {
        Name = "${var.prefix}-${var.environment}-logs"
      })
    }
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = merge(local.common_tags, {
        Name = "${var.prefix}-${var.environment}-s3"
      })
    }
  }

  tags = local.common_tags
}
