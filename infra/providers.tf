# Primary provider (ap-northeast-1)
# Credentials: set AWS_PROFILE=flap1 or export credentials via env vars
provider "aws" {
  region = var.aws_region
}

# ACM certificates for CloudFront must be in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
