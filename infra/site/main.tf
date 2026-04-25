data "aws_caller_identity" "current" {}

# Hosted zone created by the bootstrap stack — looked up by name so this
# stack stays decoupled from bootstrap state.
data "aws_route53_zone" "site" {
  name         = var.domain_name
  private_zone = false
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  site_bucket = "${var.project}-content-${local.account_id}"
}
