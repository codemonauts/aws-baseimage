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

# Target architecture of the AMI. No default on purpose.
variable "arch" {
  type = string

  validation {
    condition     = contains(["amd64", "arm64"], var.arch)
    error_message = "The arch variable must be either amd64 or arm64."
  }
}

# Debian release of the base image to build on. No default on purpose.
variable "codename" {
  type = string

  validation {
    condition     = contains(["bookworm", "trixie"], var.codename)
    error_message = "The codename variable must be either bookworm or trixie."
  }
}

# PHP version to install. No default on purpose.
variable "php_version" {
  type = string
}

# Instance types to build on, per architecture
variable "instance_types" {
  type = map(string)
  default = {
    amd64 = "c7a.large"
    arm64 = "c7g.large"
  }
}

locals {
  # 8.3 -> 83, as used in the AMI name
  php_short = replace(var.php_version, ".", "")
}

# Our own base image, built by baseimage.pkr.hcl
data "amazon-ami" "base" {
  filters = {
    name             = "codemonauts-${var.arch}-${var.codename}-base_*"
    root-device-type = "ebs"
  }
  most_recent = true
  owners      = ["self"]
  region      = "eu-central-1"
}

source "amazon-ebs" "webserver" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-${var.arch}-${var.codename}-webserver-php${local.php_short}_${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = var.instance_types[var.arch]
  region        = "eu-central-1"
  source_ami    = data.amazon-ami.base.id
  # the base image disables the admin user, so come in as cmonauts
  ssh_agent_auth = true
  ssh_username   = "cmonauts"
}

build {
  name    = "webserver"
  sources = ["source.amazon-ebs.webserver"]

  provisioner "shell" {
    pause_before = "10s"
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade"
    ]
  }

  provisioner "ansible-local" {
    playbook_dir    = "./"
    playbook_file   = "webserver.yaml"
    extra_arguments = ["--extra-vars", "php_version=${var.php_version}"]
  }
}
