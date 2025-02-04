packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    amazon-ami-management = {
      version = ">= 1.6.1"
      source  = "github.com/wata727/amazon-ami-management"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

# Instance types to use
variable "amd64_instance_type" {
  default = "c7a.large"
}
variable "arm64_instance_type" {
  default = "c7g.large"
}

# Provider of the Debian base images
variable "account_id" {
  default = "136693071363"
}

data "amazon-ami" "debian-amd64-bookworm" {
  filters = {
    name                = "debian-12-amd64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["${var.account_id}"]
  region      = "eu-central-1"
}

data "amazon-ami" "debian-arm64-bookworm" {
  filters = {
    name                = "debian-12-arm64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["${var.account_id}"]
  region      = "eu-central-1"
}

# codemonauts-amd64-bookworm-webserver-php83
source "amazon-ebs" "codemonauts-amd64-bookworm-webserver-php83" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-amd64-bookworm-webserver-php83_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.amd64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.debian-amd64-bookworm.id}"
  ssh_username  = "admin"
  tags = {
    Amazon_AMI_Management_Identifier = "codemonauts-amd64-bookworm-webserver-php83"
  }
}
build {
  name    = "codemonauts-amd64-bookworm-webserver-php83"
  sources = ["source.amazon-ebs.codemonauts-amd64-bookworm-webserver-php83"]

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "webserver.yaml"
        extra_arguments = [ 
      "-e",
      "php_version=8.3" 
    ]
  }

  post-processor "amazon-ami-management" {
    identifier    = "codemonauts-amd64-bookworm-webserver-php83"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# codemonauts-arm64-bookworm-webserver-php83
source "amazon-ebs" "codemonauts-arm64-bookworm-webserver-php83" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm64-bookworm-webserver-php83_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.arm64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.debian-arm64-bookworm.id}"
  ssh_username  = "admin"
  tags = {
    Amazon_AMI_Management_Identifier = "codemonauts-arm64-bookworm-webserver-php83"
  }
}
build {
  name    = "codemonauts-arm64-bookworm-webserver-php83"
  sources = ["source.amazon-ebs.codemonauts-arm64-bookworm-webserver-php83"]

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "webserver.yaml"
        extra_arguments = [ 
      "-e",
      "php_version=8.3" 
    ]
  }

  post-processor "amazon-ami-management" {
    identifier    = "codemonauts-arm64-bookworm-webserver-php83"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}
