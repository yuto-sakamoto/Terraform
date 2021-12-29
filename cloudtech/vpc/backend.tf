###############
## Terraform ##
###############
terraform {
  required_version = ">=1.0.0"
  backend "s3" {
    bucket  = "terraform-sd-practice-bucket"
    region  = "ap-northeast-1"
    profile = "y-sakamoto"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

