######################################
#--------------AWS KMS---------------#
######################################

module "kms_terraform_state" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  description         = "KMS key for Terraform state bucket encryption"
  enable_key_rotation = true

  aliases = ["alias/terraform-bucket-key"]

  tags = local.common_tags
}

######################################
#-------------AWS Bucket-------------#
######################################

module "s3_terraform" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${local.resources_prefix_name}-terraform-state"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms_terraform_state.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  attach_public_policy = false
  attach_policy        = true
  policy               = data.aws_iam_policy_document.s3_bucket_policy.json

  tags = merge(local.common_tags, {
    Name = "S3 Remote Terraform State Store"
  })
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "RootAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.resources_prefix_name}-terraform-state",
      "arn:aws:s3:::${local.resources_prefix_name}-terraform-state/*"
    ]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.resources_prefix_name}-terraform-state",
      "arn:aws:s3:::${local.resources_prefix_name}-terraform-state/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
