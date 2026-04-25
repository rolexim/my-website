variable "aws_region" {
  description = "AWS region for the site bucket. Pinned to us-east-1 so ACM (required there for CloudFront) and S3 share one provider."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project slug; must match bootstrap."
  type        = string
  default     = "rolando-website"
}

variable "domain_name" {
  description = "FQDN served by the distribution."
  type        = string
  default     = "rolando.solstud.io"
}

variable "tags" {
  description = "Default tags."
  type        = map(string)
  default = {
    Project   = "rolando-website"
    ManagedBy = "Terraform"
    Stack     = "site"
  }
}
