packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    amazon-ami-management = {
      version = ">= 1.2.0"
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

# Provider of the Ubuntu base images
variable "cannonical_account_id" {
  default = "099720109477"
}

data "amazon-ami" "ubuntu-jammy-amd64" {
  filters = {
    name                = "ubuntu-minimal/images/*ubuntu-jammy-22.04-amd64-minimal-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["${var.cannonical_account_id}"]
  region      = "eu-central-1"
}

data "amazon-ami" "ubuntu-jammy-arm64" {
  filters = {
    name                = "ubuntu-minimal/images/*ubuntu-jammy-22.04-arm64-minimal-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["${var.cannonical_account_id}"]
  region      = "eu-central-1"
}

# amd64-web-jammy-php74
source "amazon-ebs" "amd64-web-jammy-php74" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-amd64-web-jammy-php74_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.amd64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-amd64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "amd64-web-jammy-php74"
  }
}
build {
  name    = "amd64-web-jammy-php74"
  sources = ["source.amazon-ebs.amd64-web-jammy-php74"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y install python3-pip",
      "sudo pip3 install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "webserver.yaml"
    extra_arguments = [ 
      "-e",
      "php_version=7.4" 
    ]
  }

  post-processor "amazon-ami-management" {
    identifier    = "amd64-web-jammy-php74"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# amd64-base-jammy
source "amazon-ebs" "amd64-base-jammy" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-amd64-base-jammy_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.amd64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-amd64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "amd64-base-jammy"
  }
}
build {
  name    = "amd64-base-jammy"
  sources = ["source.amazon-ebs.amd64-base-jammy"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y install python3-pip",
      "sudo pip3 install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "baseimage.yaml"
  }

  post-processor "amazon-ami-management" {
    identifier    = "amd64-base-jammy"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# arm64-web-jammy-php83
source "amazon-ebs" "arm64-web-jammy-php83" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm64-web-jammy-php83_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.arm64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-arm64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "arm64-web-jammy-php83"
  }
}
build {
  name    = "arm64-web-jammy-php83"
  sources = ["source.amazon-ebs.arm64-web-jammy-php83"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y install python3-pip",
      "sudo pip3 install ansible"
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
    identifier    = "arm64-web-jammy-php83"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# arm64-web-jammy-php81
source "amazon-ebs" "arm64-web-jammy-php81" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm64-web-jammy-php81_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.arm64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-arm64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "arm64-web-jammy-php81"
  }
}
build {
  name    = "arm64-web-jammy-php81"
  sources = ["source.amazon-ebs.arm64-web-jammy-php81"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y install python3-pip",
      "sudo pip3 install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "webserver.yaml"
    extra_arguments = [ 
      "-e",
      "php_version=8.1" 
    ]
  }

  post-processor "amazon-ami-management" {
    identifier    = "arm64-web-jammy-php81"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# arm-base-jammy
source "amazon-ebs" "arm64-base-jammy" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm64-base-jammy_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "${var.arm64_instance_type}"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-arm64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "arm64-base-jammy"
  }
}
build {
  name    = "arm64-base-jammy"
  sources = ["source.amazon-ebs.arm64-base-jammy"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade"]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y install python3-pip",
      "sudo pip3 install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir  = "./"
    playbook_file = "baseimage.yaml"
  }

  post-processor "amazon-ami-management" {
    identifier    = "arm64-base-jammy"
    keep_releases = "3"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}
