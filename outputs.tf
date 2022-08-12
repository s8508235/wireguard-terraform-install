output "ec2_instance_dns" {
  value = aws_instance.wireguard.public_dns
}

output "ec2_instance_ip" {
  value = aws_instance.wireguard.public_ip
}

output "connection_string" {
  value = "'ssh -i ${var.ssh_private_key_file} ${var.ec2_username}@${aws_instance.wireguard.public_dns}'"
}

output "start_vpn_command" {
  value = "wg-quick up ${var.wiregaurd_config_name}"
}
