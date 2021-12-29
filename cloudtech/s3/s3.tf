###############
## 変数 ##
###############
variable "aws_profile" {
  default = "y-sakamoto"
}
variable "aws_region" {
  default = "ap-northeast-1"
}

###############
## Terraform ##
###############
terraform {
  required_version = ">=1.0.0"
}

###############
## Provider ##
###############
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  version = "~> 3.68.0"
}


resource "aws_s3_bucket" "test_versioning_bucket" {
  bucket = "terraform-sd-practice-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix  = "*.tfstate"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}
