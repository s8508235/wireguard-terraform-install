resource "aws_vpc" "wireguard" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_subnet" "wireguard" {
  availability_zone = "ap-northeast-3a"
  vpc_id     = aws_vpc.wireguard.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 0)

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_internet_gateway" "wireguard" {
  vpc_id = aws_vpc.wireguard.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "aws_route_table" "wireguard" {
  vpc_id = aws_vpc.wireguard.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wireguard.id
  }
}

resource "aws_route_table_association" "wireguard" {
  subnet_id      = aws_subnet.wireguard.id
  route_table_id = aws_route_table.wireguard.id
}

resource "aws_security_group" "wireguard" {
  name        = "wireguard"
  description = "Allow inbound UDP access to wireguard and unrestricted egress"

  vpc_id = aws_vpc.wireguard.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }

  ingress {
    from_port   = var.remote_wireguard_port
    to_port     = var.remote_wireguard_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_from_local" {
  name        = "ssh-from-local"
  description = "Allow SSH access only from local machine"

  vpc_id = aws_vpc.wireguard.id

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip_address]
  }
}

