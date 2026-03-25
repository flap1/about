terraform {
  backend "s3" {
    bucket       = "flap1-terraform-state"
    key          = "about/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
