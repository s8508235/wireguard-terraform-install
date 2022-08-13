data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "remote-config" {
  template = file("${path.module}/templates/remote-config.tpl")

  vars = {
    private_key         = file(var.remote_wireguard_private_key_file)
    dns                 = var.dns
    wg_server_net       = var.wireguard_remote_ip_subnet
    wg_server_port      = var.remote_wireguard_port
    peer                = data.template_file.wg_client_data_json.rendered
    wg_server_interface = var.wireguard_server_interface
  }
}
data "template_file" "wg_client_data_json" {
  template = file("${path.module}/templates/client-data.tpl")

  vars = {
    client_pub_key = file(var.local_wireguard_public_key_file)
    wg_subnet      = var.wireguard_ip_subnet
    client_ip      = cidrhost(local.local_ip_address, 0)
    client_port    = var.local_wireguard_port
  }
}

data "template_file" "local_config_file" {
  template = file("${path.module}/templates/local-config.tpl")
  vars = {
    local_private_key = file(var.local_wireguard_private_key_file)
    wg_subnet         = var.wireguard_local_ip_subnet
    local_port        = var.local_wireguard_port
    dns               = var.dns
    local_gateway     = var.local_gateway
    local_ip          = local.local_ip_address
    remote_public_key = file(var.remote_wireguard_public_key_file)
    remote_ip         = aws_instance.wireguard.public_ip
    remote_port       = var.remote_wireguard_port
  }
}

resource "aws_key_pair" "wireguard" {
  key_name   = var.ssh_private_key_file
  public_key = file("${path.module}/${var.ssh_public_key_file}")
}

resource "aws_instance" "wireguard" {
  ami                         = data.aws_ami.amazon_linux_2.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.wireguard.key_name
  subnet_id                   = aws_subnet.wireguard.id
  vpc_security_group_ids = [
    aws_security_group.wireguard.id,
    aws_security_group.ssh_from_local.id,
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.instance_root_block_device_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = var.tag_name
    Provisioner = "Terraform"
  }
}

resource "null_resource" "wireguard_bootstrap" {
  connection {
    type        = "ssh"
    host        = aws_instance.wireguard.public_ip
    user        = var.ec2_username
    port        = "22"
    private_key = file("${path.module}/${var.ssh_private_key_file}")
    agent       = false
  }
  provisioner "file" {
    content     = data.template_file.remote-config.rendered
    destination = "/tmp/wg0.conf"
  }

  provisioner "file" {
    source      = "${path.module}/install.sh"
    destination = "/tmp/install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install epel -y",
      "sudo chmod +x /tmp/install.sh",
      "sudo yum clean all -y",
      "sudo /tmp/install.sh",
      "sudo yum install wireguard-dkms wireguard-tools -y",
      "sudo cp /tmp/wg0.conf /etc/wireguard/wg0.conf",
      "sudo wg-quick up wg0",
    ]
  }
}

resource "local_file" "wireguard_local_file" {
  depends_on      = [null_resource.wireguard_bootstrap]
  content         = data.template_file.local_config_file.rendered
  filename        = "${path.module}/${var.wiregaurd_config_name}"
  file_permission = "0400"
}
