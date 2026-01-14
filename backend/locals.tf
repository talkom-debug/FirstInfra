locals {
  general = {
    env_name = var.env_name
    prefix   = var.prefix
  }

  global_tags = {
    "project"    = "datalake"
    "created_by" = "terraform"
  }

  resources_prefix_name = "${local.general.env_name}-${local.general.prefix}"
}
