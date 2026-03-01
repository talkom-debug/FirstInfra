locals {
  resources_prefix_name = "${var.env_name}-${var.prefix}"

  common_tags = merge(
    {
      Project     = var.prefix
      Environment = var.env_name
      Owner       = var.owner
    },
    var.tags
  )
}
