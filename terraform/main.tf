# Specify the provider and access details
provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH.
resource "aws_security_group" "default" {
  name        = "generic_security_group"
  description = "Allows SSH and outbound connections"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "salt" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install SaltStack from their official PPA.
  provisioner "remote-exec" {
    inline = [
      "sudo hostname salt",
      "sudo bash -c 'echo salt > /etc/hostname'",
      "sudo bash -c 'echo -e \"127.0.0.1\tsalt\n\" >> /etc/hosts'",
      "sudo add-apt-repository -y ppa:saltstack/salt",
      "sudo apt-get update",
      "sudo apt-get -y install salt-master salt-minion git",
      "sleep 10", # To ensure the minion has time to send the signing request
      "sudo salt-key -y -A",
      "sudo bash -c 'cd /root && git clone https://github.com/wsandin/effective-broccoli.git'",
      "sudo ln -s /root/effective-broccoli/salt /srv/salt",
      "sudo bash -c 'echo \"startup_states: highstate\" > /etc/salt/minion'",
      "sudo /etc/init.d/salt-minion restart"
    ]
  }
}
