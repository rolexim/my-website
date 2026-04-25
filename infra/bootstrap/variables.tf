variable "aws_region" {
  description = "AWS region for the Terraform state bucket. CloudFront/ACM resources in the site stack are pinned to us-east-1 regardless."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project slug used to derive resource names. Lowercase, no spaces."
  type        = string
  default     = "rolando-website"
}

variable "domain_name" {
  description = "Fully-qualified domain name for the site. A Route 53 hosted zone is created for this name; NS records must be delegated from the parent zone."
  type        = string
  default     = "rolando.solstud.io"
}

variable "github_repository" {
  description = "GitHub repository the deploy role trusts, in 'owner/name' form (e.g. 'rcontrerasj/my-website'). The OIDC trust condition is scoped to this repo."
  type        = string
}

variable "github_branch" {
  description = "Branch from which deploys are allowed. The OIDC trust condition allows this ref and (optionally) PR contexts."
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default = {
    Project   = "rolando-website"
    ManagedBy = "Terraform"
    Stack     = "bootstrap"
  }
}
