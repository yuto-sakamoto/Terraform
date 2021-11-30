variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {
}

###############
## Provider ##
###############
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
resource "aws_ecr_repository" "gbc" {
  name                 = "gbc1sys/todobackend"
  image_tag_mutability = "MUTABLE"
  # tags {
  #   name = "test"
  # }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.gbc.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
