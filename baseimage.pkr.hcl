packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

# Region the images are built in and stored. No copies to other regions.
variable "region" {
  type    = string
  default = "eu-central-1"
}

# Target architecture of the AMI. No default on purpose.
variable "arch" {
  type = string

  validation {
    condition     = contains(["amd64", "arm64"], var.arch)
    error_message = "The arch variable must be either amd64 or arm64."
  }
}

# Debian release to build from. No default on purpose.
variable "codename" {
  type = string

  validation {
    condition     = contains(["bookworm", "trixie"], var.codename)
    error_message = "The codename variable must be either bookworm or trixie."
  }
}

# Debian major version per release
variable "debian_majors" {
  type = map(string)
  default = {
    bookworm = "12"
    trixie   = "13"
  }
}

# Instance types to build on, per architecture
variable "instance_types" {
  type = map(string)
  default = {
    amd64 = "c7a.large"
    arm64 = "c7g.large"
  }
}

# Provider of the Debian base images
variable "account_id" {
  default = "136693071363"
}

data "amazon-ami" "debian" {
  filters = {
    name                = "debian-${var.debian_majors[var.codename]}-${var.arch}-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = [var.account_id]
  region      = var.region
}

source "amazon-ebs" "base" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-${var.arch}-${var.codename}-base_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  instance_type = var.instance_types[var.arch]
  region        = var.region
  source_ami    = data.amazon-ami.debian.id
  ssh_username  = "admin"
}

build {
  name    = "base"
  sources = ["source.amazon-ebs.base"]

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
    playbook_file = "baseimage.yaml"
  }
}
