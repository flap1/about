variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "flap1.com"
}

variable "aws_region" {
  description = "AWS region for S3 bucket"
  type        = string
  default     = "ap-northeast-1"
}
