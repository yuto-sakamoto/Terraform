variable "project_name" {
  default = "sd"
}
variable "environment" {
  default = "staging"
}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {
  default = "y-sakamoto"
}
variable "subnet_ids" {
  default = {
    "ap-northeast-1a" = "subnet-05a36e44b59902960"
    "ap-northeast-1c" = "subnet-038fecec7ae366e20"
  }
}

variable "office_ips" {
  default = {
    "sakamoto" = "119.239.229.168/32"
    "test"     = "192.168.0.1/32"
  }
}

variable "vpn_ips" {
  default = {
    "mori"  = "119.239.229.168/32"
    "test2" = "192.168.0.2/32"
  }
}

variable "ec2_key_pair" {
  default = "ssh-rsa SOMETHINGHERE administrator@sd.local"
}

variable "vpc_id" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}
variable "root_volume_type" {
  default = "gp3"
}
variable "root_volume_size" {
  default = "20"
}
