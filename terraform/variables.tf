variable "public_key_path" {
  description = <<DESCRIPTION
Please enter path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect. At this point AWS only supports RSA keys (up to 4096 bits). 
Ed25519 won't work!
Example: ~/.ssh/salt.pub
DESCRIPTION
}

variable "key_name" {
  description = <<DESCRIPTION
This is the name that will appear in the AWS console for your .pem (SSH) key.
Example: salt
DESCRIPTION
}

variable "aws_profile" {
  description = <<DESCRIPTION
Please enter the name of your desired AWS profile for deployment.
This profile has to be stored in ~/.aws/credentials.
DESCRIPTION
}

variable "aws_region" {
  description = "AWS region to launch servers"
  default     = "ap-southeast-2" # Asia Pacific (Sydney)
}

# Ubuntu Server 16.04 LTS (x64)
variable "aws_amis" {
  default = {
    eu-west-1      = "ami-405f7226"
    us-east-1      = "ami-fcc19b99"
    us-west-1      = "ami-16efb076"
    ap-southeast-2 = "ami-4e686b2d"
  }
}
