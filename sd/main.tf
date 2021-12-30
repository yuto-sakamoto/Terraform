###############
## locals    ##
###############
locals {
  tags = {
    poroject    = var.project_name
    environment = var.environment
    terraform   = true
  }
}
###############
## Resources ##
###############
resource "aws_key_pair" "administrator" {
  key_name   = format("%s-%s-administrator", var.project_name, var.environment)
  public_key = var.ec2_key_pair
  tags       = local.tags
}

resource "aws_security_group" "ssh" {
  name   = format("%s-%s-ssh", var.project_name, var.environment)
  vpc_id = var.vpc_id
  tags   = local.tags
}

resource "aws_security_group_rule" "ssh_egress" {
  security_group_id = aws_security_group.ssh.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "all"
}

resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.ssh.id
  type              = "ingress"
  cidr_blocks       = concat(distinct(values(var.office_ips)), distinct(values(var.vpn_ips)))
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = "ami-0e60b6d05dc38ff11"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.administrator.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = element(distinct(values(var.subnet_ids)), count.index)
  monitoring             = true
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }
  tags = local.tags
}

resource "aws_eip" "web" {
  count    = 2
  instance = element(aws_instance.web.*.id, count.index)
  vpc      = true
  tags     = local.tags
}
