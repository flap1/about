output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.site.id
}

output "nameservers" {
  description = "Set these NS records at muumuu domain for flap1.com"
  value       = aws_route53_zone.main.name_servers
}
