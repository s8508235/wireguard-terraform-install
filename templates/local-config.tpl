[Interface]
PrivateKey = ${local_private_key}
Address = ${wg_subnet}
ListenPort = ${local_port}
# DNS = ${dns}
# if you want to ssh to remote
# PostUp = ip route add ${local_ip} via ${local_gateway}
# PostDown = ip route delete ${local_ip} via ${local_gateway}
[Peer]
PublicKey = ${remote_public_key}
AllowedIPs = 0.0.0.0/0
# EC2 public IP4 and port 
Endpoint = ${remote_ip}:${remote_port}
