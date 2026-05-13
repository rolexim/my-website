provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  state_bucket  = "${var.project}-tfstate-${local.account_id}"
  oidc_provider = "token.actions.githubusercontent.com"
}

# ---------------------------------------------------------------------------
# Terraform remote state — S3 bucket (S3-native locking via use_lockfile)
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket

  # Allow `terraform destroy` to wipe the bucket — including all object
  # versions and delete-markers — without an out-of-band aws s3api purge step.
  # Only meaningful when tearing the whole project down.
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# State locking uses S3-native locks (Terraform 1.10+, `use_lockfile = true`
# in the backend config). No DynamoDB table required.

# ---------------------------------------------------------------------------
# Route 53 hosted zone for the site's subdomain.
# Parent account (solstud.io) must add NS records pointing here — see outputs.
# ---------------------------------------------------------------------------

resource "aws_route53_zone" "site" {
  name    = var.domain_name
  comment = "Subdomain zone for ${var.domain_name} — delegated from solstud.io"
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC — provider + deploy role
# ---------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.oidc_provider}"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub's root CA thumbprints; AWS ignores these in practice for the
  # token.actions.githubusercontent.com endpoint, but the field is required.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

data "aws_iam_policy_document" "deploy_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider}:sub"
      values = [
        "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}",
        "repo:${var.github_repository}:environment:production",
      ]
    }
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.project}-deploy"
  description        = "Assumed by GitHub Actions via OIDC to deploy ${var.domain_name}"
  assume_role_policy = data.aws_iam_policy_document.deploy_assume_role.json
}

data "aws_iam_policy_document" "deploy" {
  # Terraform remote state
  statement {
    sid       = "TerraformState"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "TerraformStateObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }

  # Site stack management
  statement {
    sid    = "ManageSiteResources"
    effect = "Allow"
    actions = [
      "s3:*",
      "cloudfront:*",
      "acm:*",
      "route53:*",
      "iam:GetRole",
      "iam:PassRole",
      "tag:GetResources",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "${var.project}-deploy"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}
