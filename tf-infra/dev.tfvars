prefix               = "baseinfra"
environment          = "dev"
owner                = "platform"
aws_profile          = "training"
region               = "eu-west-1"
azs                  = ["eu-west-1a", "eu-west-1b"]
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

alb_ingress_cidrs     = ["0.0.0.0/0"]
ecr_repository_name   = "hello-world"
create_ecs_resources  = false
create_cicd_resources = false

repo_owner              = "tal-komemi"
repo_name               = "firstinfra"
repo_branch             = "main"
codestar_connection_arn = "arn:aws:codeconnections:eu-west-1:791073934047"

tags = {
  ManagedBy = "terraform"
}
