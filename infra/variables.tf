variable "primary_domain" {
  description = "Canonical domain that serves the real site content"
  type        = string
  default     = "shoichiseto.com"
}

variable "redirect_domain" {
  description = "Domain that 301-redirects everything to primary_domain"
  type        = string
  default     = "flap1.com"
}

variable "content_bucket_name" {
  description = "S3 bucket name backing the primary site. Kept stable across domain renames -- it's an internal storage identifier, never seen by visitors (behind CloudFront + OAC), so there's no need to migrate data just to match the current canonical domain."
  type        = string
  default     = "flap1.com"
}

variable "aws_region" {
  description = "AWS region for S3 bucket"
  type        = string
  default     = "ap-northeast-1"
}
