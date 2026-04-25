# Single provider in us-east-1 so the ACM cert (which CloudFront requires in
# us-east-1) and the rest of the resources share one provider config.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}
