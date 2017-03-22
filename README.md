# effective-broccoli
Efficient AWS and SaltStack deployment using Terraform.

This proof of concept accomplishes three things:
* Provisioning of infrastructure onto AWS
* Installation of SaltStack and states
* Applies a state with 3 users and a log counting script executed by cron every 30 minutes

### Deployment
This assumes that you have Terraform, aws-cli and OpenSSH installed, and that you cloned this repository already.

https://www.terraform.io/intro/getting-started/install.html
https://docs.aws.amazon.com/cli/latest/userguide/installing.html

#### Step 1: Configure AWS
```
$ aws configure --profile salt
AWS Access Key ID [None]: XXXXX
AWS Secret Access Key [None]: XXX
Default region name [None]:   <ENTER>
Default output format [None]: <ENTER>
```

#### Step 2: Generate SSH key-pair and add it to agent
```
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/salt -N<YOUR_PASSWORD_OF_CHOICE>
Your identification has been saved in ~/.ssh/salt.
Your public key has been saved in ~/.ssh/salt.pub.
The key fingerprint is:
SHA256:xovMDQEDL5Oi4pnS6v7DxuSyA26QQlMi8bWIYw9uVxw johndoe@tianhe-2
The key's randomart image is:
+---[RSA 4096]----+
|....+E           |
|.+ *.+.          |
|=oO oo.          |
|+=oo.  o         |
|++.o  . S        |
|O.+. o = .       |
|*+*   + o        |
|.* *             |
|=+*..            |
+----[SHA256]-----+
$ cp ~/.ssh/salt.pub effective-broccoli/salt/local_users/salt.pub
$ ssh-add ~/.ssh/salt
Enter passphrase for .ssh/salt: <YOUR_PASSWORD_OF_CHOICE>
Identity added: .ssh/salt (.ssh/salt)
```

#### Step 3: Deploy!@#
```
$ cd effective-broccoli/terraform
$ terraform apply
var.aws_profile
  Please enter the name of your desired AWS profile for deployment.
  This profile has to be stored in ~/.aws/credentials.

  Enter a value: salt

var.key_name
  This is the name that will appear in the AWS console for your .pem (SSH) key.
  Example: salt

  Enter a value: salt

var.public_key_path
  Please enter path to the SSH public key to be used for authentication.
  Ensure this keypair is added to your local SSH agent so provisioners can
  connect. At this point AWS only supports RSA keys (up to 4096 bits).
  Ed25519 won't work!
  Example: ~/.ssh/salt.pub

  Enter a value: ~/.ssh/salt.pub

$ ssh -lubuntu $(terraform output ip)
```

#### Decommissioning
```
$ cd effective-broccoli/terraform
$ terraform destroy
```
