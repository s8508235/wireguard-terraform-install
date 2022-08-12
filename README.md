## You Have

Before you can use the Terraform module in this repository out of the box, you need

 - an [AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)
 - a [Terraform](https://www.terraform.io/intro/getting-started/install.html) CLI
 - [Wireguard](https://www.wireguard.com/install/)
Moreover, you probably had enough of people snooping on you and want some privacy back or just prefer to have a long lived static IP.

## Setup

The minimal setup leverages as much of the default settings in [variables.tf](variables.tf) as possible. However some input is required.

### Providing SSH Keys

In order to bootstrap as well as manage the Wireguard peer, the Terraform module needs to SSH into the EC2 node. By default, it uses the public key in `settings/wireguard.pub` and the private key in `settings/wireguard`. Both can be created by executing the following command from the root directory of this repository.

The public key in `settings/wireguard_local`, the private key in `settings/wireguard_local.pub`, the public key in `settings/wireguard_remote` and the private key in `settings/wireguard_remote.pub` are required for wireguard config generation.
```
cd settings
ssh-keygen -f wireguard -t rsa -b 4096
wg genkey | tee wireguard_local | wg pubkey > wireguard_local.pub
wg genkey | tee wireguard_remote | wg pubkey > wireguard_remote.pub
```
Here, hit return when prompted for a password in order to make the SSH keys passwordless.

### Configuring Your Settings

The minimum input variables for the module are defined in [settings/example.tfvars](settings/example.tfvars) to be
```hcl
aws_region = "<your-region>"

shared_credentials_file = "/path/to/.aws/credentials"

profile = "<your-profile>"

```

## Execution

All Terraform interactions are wrapped in helper Bash scripts for convenience.

### Initialising Terraform

Initialise Terraform by running
```
./terraform-bootstrap.sh
```

### Applying the Terraform Configuration

The Wireguard peer can be created and updated by running
```
./terraform-apply.sh <input-file-name>
```
where `<input-file-name>` references input file `settings/<input-file-name>.tfvars`.
When using input file [settings/example.tfvars](settings/example.tfvars) configured above, the command becomes
```
./terraform-apply.sh example
```
Under the bonnet, the `terraform-apply.sh` Bash script with input `example`
 - selects or creates a new workspace called `example`
 - executes `terraform apply` where the inputs are taken from input file `settings/example.tfvars`
 - does not ask for permission to proceed as it uses `-auto-approve` when running the underlying `terraform apply` command


## Terraform Outputs

Additionally, the Terraform module also outputs
 - the `ec2_instance_dns`
 - the `ec2_instance_ip` and
 - a `connection_string` that can be used to SSH into the EC2 node 

## Deletion

The Wireguard can be deleted by running
```
./terraform-destroy.sh <input-file-name>
```
where `<input-file-name>` again references input file `settings/<input-file-name>.tfvars`.
When using input file [settings/example.tfvars](settings/example.tfvars) configured above, the command becomes
```
./terraform-destroy.sh example
```

Under the bonnet, the `terraform-destroy.sh` Bash script with input `example`
 - selects the `example` workspace
 - executes `terraform destroy` where the inputs are taken from file `settings/example.tfvars`
 - _does ask for permission_ to proceed when running the `terraform apply` command

After that, you should not use the generated wireguard config anymore.

## Testing VPN Connectivity

Once the Terraform module execution has successfully completed, the connection to the Wireguard peer can be tested as follows. 
```
wireguard up ${CONFIG_FILE}
```
> Note that the above command will actually change your network settings and hence public IP.


## Credits

This repository forked from [dumrauf/openvpn-terraform-install](https://github.com/dumrauf/openvpn-terraform-install),
use some ideas from [jmhale/terraform-aws-wireguard](https://github.com/jmhale/terraform-aws-wireguard), and
this [article](https://www.cyberciti.biz/faq/install-set-up-wireguard-on-amazon-linux-2/)
## FAQs

Below is a list of frequently asked questions.

### I Cannot SSH Into the Wireguard peer Any Longer!

Most likely, the IP address of your machine executing the Terraform module has changed since the original installation. The security groups for the Wireguard peer are designed to only permit SSH access from a single predefined IP address. As this has drifted from the original value, you are being refused SSH access. But this scenario has been incorporated into the design of the Terraform module.

Just re-run the `./terraform-apply.sh` Bash script again with your `<input-file-name>`. Terraform should pick up your new IP address and update the ingress rules for the security groups accordingly.

### Wait — There's a Pint Bounty in the Code?!

Yes. Find it. Solve it. Bag your reward. I'm looking forward to your solutions! Teach me something new!
