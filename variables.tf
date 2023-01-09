variable "aws_region" {
  description = "The AWS region to use"
  default     = "eu-west-2"
}

variable "shared_credentials_file" {
  description = "The location of the AWS shared credentials file (e.g. ~dominic/.aws/credentials)"
}

variable "profile" {
  description = "The profile to use"
}

variable "tag_name" {
  description = "The name to tag AWS resources with"
  default     = "Wiregaurd"
}

variable "cidr_block" {
  description = "The CIDR block range to use for the Wiregaurd VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "The instance type to use"
  default     = "t2.micro"
}

variable "instance_root_block_device_volume_size" {
  description = "The size of the root block device volume of the EC2 instance in GiB"
  default     = 8
}

variable "ec2_username" {
  description = "The user to connect to the EC2 as"
  default     = "ec2-user"
}

variable "ssh_public_key_file" {
  # Generate via 'ssh-keygen -f wireguard -t rsa -b 4096'
  description = "The public SSH key to store in the EC2 instance"
  default     = "settings/wireguard.pub"
}

variable "ssh_private_key_file" {
  # Generate via 'ssh-keygen -f wireguard -t rsa -b 4096'
  description = "The private SSH key used to connect to the EC2 instance"
  default     = "settings/wireguard"
}

variable "remote_wireguard_port" {
  description = "The expose port for wireguard on the EC2 instance"
  default     = "51820"
}

variable "local_wireguard_port" {
  description = "The expose port for wireguard on your machine"
  default     = "51820"
}

variable "wireguard_ip_subnet" {
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
  default     = "10.8.0.0/24"
}

variable "wireguard_remote_ip_subnet" {
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
  default     = "10.8.0.1/24"
}

variable "wireguard_local_ip_subnet" {
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
  default     = "10.8.0.2/24"
}

variable "local_wireguard_public_key_file" {
  # Generate via 'wg genkey | tee settings/wireguard_local | wg pubkey > settings/wireguard_local.pub'
  description = "The local public key for wireguard config"
  default     = "settings/wireguard_local.pub"
}

variable "local_wireguard_private_key_file" {
  # Generate via 'wg genkey | tee settings/wireguard_local | wg pubkey > settings/wireguard_local.pub'
  description = "The local private key for wireguard config"
  default     = "settings/wireguard_local"
}

variable "remote_wireguard_public_key_file" {
  # Generate via 'wg genkey | tee settings/wireguard_remote | wg pubkey > settings/wireguard_remote.pub'
  description = "The remote public key for wireguard config"
  default     = "settings/wireguard_remote.pub"
}

variable "remote_wireguard_private_key_file" {
  # Generate via 'wg genkey | tee settings/wireguard_remote | wg pubkey > settings/wireguard_remote.pub'
  description = "The remote private key for wireguard config"
  default     = "settings/wireguard_remote"
}

variable "wireguard_server_interface" {
  description = "The default interface to forward network traffic to"
  default     = "ens5"
}

variable "wiregaurd_config_name" {
  description = "The wireguard config name on your machine"
  default     = "settings/wg0.conf"
}

variable "local_gateway" {
  description = "The local gateway if you want to ssh to remote EC2 instance"
  default     = "192.168.0.1"
}

variable "dns" {
  type        = list(string)
  description = "dns"
  default     = ["8.8.8.8"]
}
