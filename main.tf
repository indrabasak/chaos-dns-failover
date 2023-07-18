terraform {
  backend "local" {}
}

// Set policy to deny non-HTTPS traffic
data "aws_iam_policy_document" "s3_backend_write" {
  policy_id = "s3-backend-write-${var.bucket}"

  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.bucket}"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.bucket
  acl           = "private"
  policy        = data.aws_iam_policy_document.s3_backend_write.json
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    mfa_delete = false
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# /////////////////////////////////////////////////////////////////////////////////
#module "lambda_function" {
#  source = "./modules/lambda-function"
#}

module "api_gateway" {
  source = "./modules/api-gateway"
  rest_api_name = var.rest_api_name
  rest_api_stage_name = var.rest_api_stage_name
  root_domain = var.root_domain
  subdomain = var.subdomain
  health_check_name = var.health_check_name
  route53_failover_routing_policy = var.route53_failover_routing_policy
  route53_identifier = var.route53_identifier
}
