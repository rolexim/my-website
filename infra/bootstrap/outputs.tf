output "state_bucket" {
  description = "S3 bucket holding Terraform state for the site stack."
  value       = aws_s3_bucket.tfstate.id
}

output "deploy_role_arn" {
  description = "ARN of the role GitHub Actions assumes via OIDC. Add this as a GitHub Actions repo variable named AWS_DEPLOY_ROLE_ARN."
  value       = aws_iam_role.deploy.arn
}

output "zone_id" {
  description = "Route 53 hosted zone ID for the site subdomain."
  value       = aws_route53_zone.site.zone_id
}

output "zone_name_servers" {
  description = "Add these NS records under the parent zone (solstud.io) to delegate the subdomain. One-time manual step in the parent account."
  value       = aws_route53_zone.site.name_servers
}
