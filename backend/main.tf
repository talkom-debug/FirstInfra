######################################
#--------------AWS KMS---------------#
######################################

resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}

######################################
#-------------AWS Bucket-------------#
######################################

module "s3_terraform" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.1"

  bucket = "${local.resources_prefix_name}-terraform-state"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  attach_public_policy = false
  attach_policy        = true
  policy               = data.aws_iam_policy_document.s3_bucket_policy.json

  tags = {
    Name = "S3 Remote Terraform State Store"
  }
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

######################################
#------------AWS DynamoDB------------#
######################################

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${local.resources_prefix_name}-terraform-locks"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
