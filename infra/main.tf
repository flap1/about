# ============================================================
# S3 Bucket (static files, no public access)
# ============================================================

resource "aws_s3_bucket" "site" {
  bucket = var.content_bucket_name
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Suspended"
  }
}

# ============================================================
# ACM Certificate (us-east-1, required for CloudFront)
# One certificate covers both domains -- shared by the content
# distribution (primary_domain) and the redirect distribution (redirect_domain).
# ============================================================

resource "aws_acm_certificate" "site" {
  provider    = aws.us_east_1
  domain_name = var.primary_domain
  subject_alternative_names = [
    "www.${var.primary_domain}",
    "*.${var.primary_domain}",
    var.redirect_domain,
    "www.${var.redirect_domain}",
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "site" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# ============================================================
# Route 53 Hosted Zones
# ============================================================

resource "aws_route53_zone" "primary" {
  name = var.primary_domain
}

# Already delegated at the registrar -- kept in place (see moved.tf) rather
# than recreated, so flap1.com's live NS delegation is never disturbed.
resource "aws_route53_zone" "redirect" {
  name = var.redirect_domain
}

locals {
  # Maps each SAN in the shared cert to the zone that should hold its
  # DNS validation record.
  cert_validation_zone_by_domain = {
    (var.primary_domain)         = aws_route53_zone.primary.zone_id
    "www.${var.primary_domain}"  = aws_route53_zone.primary.zone_id
    "*.${var.primary_domain}"    = aws_route53_zone.primary.zone_id
    (var.redirect_domain)        = aws_route53_zone.redirect.zone_id
    "www.${var.redirect_domain}" = aws_route53_zone.redirect.zone_id
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.cert_validation_zone_by_domain[each.key]
}

# ============================================================
# Route 53 Records (A/AAAA Alias -> CloudFront)
# ============================================================

# primary_domain -> content distribution
resource "aws_route53_record" "primary_root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.primary_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "primary_root_aaaa" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.primary_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "primary_www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.primary_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "primary_www_aaaa" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.primary_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# redirect_domain -> redirect distribution (301 to primary_domain)
resource "aws_route53_record" "redirect_root" {
  zone_id = aws_route53_zone.redirect.zone_id
  name    = var.redirect_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_root_aaaa" {
  zone_id = aws_route53_zone.redirect.zone_id
  name    = var.redirect_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_www" {
  zone_id = aws_route53_zone.redirect.zone_id
  name    = "www.${var.redirect_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_www_aaaa" {
  zone_id = aws_route53_zone.redirect.zone_id
  name    = "www.${var.redirect_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

# ============================================================
# CloudFront Origin Access Control (OAC)
# ============================================================

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.content_bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ============================================================
# CloudFront Function (URL rewrite: /path -> /path/index.html)
# ============================================================

resource "aws_cloudfront_function" "url_rewrite" {
  name    = "url-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/functions/url-rewrite.js")
}

# ============================================================
# CloudFront Distribution
# ============================================================

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.primary_domain, "www.${var.primary_domain}"]
  price_class         = "PriceClass_200"
  http_version        = "http2and3"
  comment             = "${var.primary_domain} static site"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${var.content_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${var.content_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id            = aws_cloudfront_cache_policy.site.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  # Long cache for hashed assets (_astro/*)
  ordered_cache_behavior {
    path_pattern           = "_astro/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${var.content_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id            = aws_cloudfront_cache_policy.immutable.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }
}

# ============================================================
# CloudFront Distribution (redirect_domain -> 301 to primary_domain)
# ============================================================

resource "aws_cloudfront_function" "redirect_to_primary" {
  name    = "redirect-to-${replace(var.primary_domain, ".", "-")}"
  runtime = "cloudfront-js-2.0"
  publish = true
  code = templatefile("${path.module}/functions/redirect-to-primary.js.tpl", {
    primary_domain = var.primary_domain
  })
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "redirect" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.redirect_domain, "www.${var.redirect_domain}"]
  price_class     = "PriceClass_200"
  http_version    = "http2and3"
  comment         = "${var.redirect_domain} -> ${var.primary_domain} redirect"

  # ponytail: origin is never actually fetched -- the function short-circuits
  # every request at viewer-request -- but CloudFront requires one to be
  # configured, so the existing bucket is reused rather than provisioning a
  # throwaway one.
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "unused-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "unused-origin"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_to_primary.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# ============================================================
# Cache Policies
# ============================================================

resource "aws_cloudfront_cache_policy" "site" {
  name        = "${replace(var.content_bucket_name, ".", "-")}-default"
  default_ttl = 86400
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "immutable" {
  name        = "${replace(var.content_bucket_name, ".", "-")}-immutable"
  default_ttl = 31536000
  max_ttl     = 31536000
  min_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

# ============================================================
# Response Headers Policy (security headers)
# ============================================================

resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${replace(var.content_bucket_name, ".", "-")}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    content_security_policy {
      # ponytail: the one inline bootstrap script (adds a `js` class) is
      # allowed by hash rather than 'unsafe-inline'; recompute if it ever
      # changes -- printf '%s' '<script body>' | openssl dgst -sha256 -binary | openssl base64
      content_security_policy = "default-src 'self'; script-src 'self' 'sha256-/x7W7R75k8Roq0WaVRQX9blP4OufE5xbAdzklGxsgpw='; style-src 'self'; img-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; object-src 'none'"
      override                = true
    }
  }
}

# ============================================================
# S3 Bucket Policy (CloudFront OAC access only)
# ============================================================

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
          }
        }
      }
    ]
  })
}
