output "cloudfront_distribution_id" {
  description = "Content CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Content CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "redirect_cloudfront_distribution_id" {
  description = "Redirect CloudFront distribution ID (flap1.com -> shoichiseto.com)"
  value       = aws_cloudfront_distribution.redirect.id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.site.id
}

output "primary_nameservers" {
  description = "Set these NS records at the registrar for shoichiseto.com (currently on muumuu-domain)"
  value       = aws_route53_zone.primary.name_servers
}

output "redirect_nameservers" {
  description = "flap1.com's existing NS records -- already set at the registrar, no change needed"
  value       = aws_route53_zone.redirect.name_servers
}
