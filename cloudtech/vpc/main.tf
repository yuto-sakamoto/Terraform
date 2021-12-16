#############
## 変数定義 ##
#############
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {}
variable "cidr_range" {}
variable "cidr_public1" {}
variable "cidr_public2" {}
variable "cidr_private1" {}
variable "cidr_private2" {}
variable "subnets" {
  type = map(any)
  default = {
    private_subnets = {
      private-1a = {
        name = "private-1a",
        cidr = "10.99.20.0/24",
        az   = "ap-northeast-1a"
      },
      private-1c = {
        name = "private-1c",
        cidr = "10.99.21.0/24",
        az   = "ap-northeast-1c"
      }
    },
    public_subnets = {
      public-1a = {
        name = "public1"
        cidr = "10.99.10.0/24"
        az   = "ap-northeast-1a"
      },
      public-1c = {
        name = "public2"
        cidr = "10.99.11.0/24"
        az   = "ap-northeast-1c"
      }
    }
  }
}
###############
## Provider ##
###############
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

###############
## Resources ##
###############
# VPC
resource "aws_vpc" "cloudtech_ecs" {
  # id                   = var.vpc_id
  cidr_block           = var.cidr_range
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "cloudtech-vpc"
  }
}

# サブネット
resource "aws_subnet" "public" {
  for_each = var.subnets.public_subnets

  vpc_id                  = aws_vpc.cloudtech_ecs.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = "true"
  tags = {
    Name = "cloudtech-${each.value.name}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.subnets.private_subnets
  vpc_id   = aws_vpc.cloudtech_ecs.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "cloudtech-${each.value.name}"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cloudtech_ecs.id

  tags = {
    Name = "cloudtech-igw"
  }
}

# ルート(public)
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public_route_t.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_internet_gateway.igw]
}
# ルートテーブル(public)
resource "aws_route_table" "public_route_t" {
  vpc_id = aws_vpc.cloudtech_ecs.id

  tags = {
    Name = "cloudtech-public-route"
  }
}
# ルートテーブル(private)
resource "aws_route_table" "private_route_t" {
  vpc_id = aws_vpc.cloudtech_ecs.id

  tags = {
    Name = "cloudtech-private-route"
  }
}

#############
## ECS ##
#############
resource "aws_ecs_cluster" "cloudtech-test-cluster" {
  name = "cloudtech-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "cloudtech-cluster-tag"
  }
}

