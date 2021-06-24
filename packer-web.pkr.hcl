packer {
  required_plugins {
    amazon-ami-management = {
      version = ">= 1.0.0"
      source = "github.com/wata727/amazon-ami-management"
    }
  }
}

data "amazon-ami" "web" {
  filters = {
    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "eu-central-1"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

source "amazon-ebs" "web" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-web-focal-php74_${legacy_isotime("2006-01-02_03-04")}"
  instance_type = "t3a.micro"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.web.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "web_focal_74"
  }
}

build {
  sources = ["source.amazon-ebs.web"]

  provisioner "shell" {
    inline = [
        "sudo apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "chef-solo" {
    chef_license   = "accept"
    cookbook_paths = ["cookbooks"]
    run_list       = ["common", "unattended-upgrades", "useraccounts", "aws_codedeploy", "web"]
  }

  post-processor "amazon-ami-management" {
    identifier    = "managed"
    keep_releases = "1"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}
