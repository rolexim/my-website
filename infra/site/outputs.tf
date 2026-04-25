output "site_bucket" {
  description = "S3 bucket holding rendered site content. CI syncs the Pelican output here."
  value       = aws_s3_bucket.site.id
}

output "distribution_id" {
  description = "CloudFront distribution ID. Used to create cache invalidations after a deploy."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_domain" {
  description = "CloudFront default domain (the *.cloudfront.net) — for debugging only; production traffic uses the custom domain."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "site_url" {
  description = "Public URL of the site."
  value       = "https://${var.domain_name}/"
}
