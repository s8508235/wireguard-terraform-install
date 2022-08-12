[Interface]
PrivateKey = ${private_key}
Address = ${wg_server_net}
ListenPort = ${wg_server_port}
DNS = ${dns}
PreUp = sysctl -w net.ipv4.ip_forward=1
# PreUp = sysctl -w net.ipv6.conf.all.forwarding=1
PostUp   = iptables -t nat -A POSTROUTING -o ${wg_server_interface} -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o ${wg_server_interface} -j MASQUERADE

${peer}
