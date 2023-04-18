packer {
  required_plugins {
    amazon-ami-management = {
      version = ">= 1.2.0"
      source  = "github.com/wata727/amazon-ami-management"
    }
  }
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

# amd-web-jammy-74
source "amazon-ebs" "amd64-web-jammy-php74" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-web-jammy-php74_${formatdate("YYYY-MM-DD-HHmm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "t3a.micro"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-amd64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "amd64_web_jammy_74"
  }
}
build {
  name    = "amd64-web-jammy-74"
  sources = ["source.amazon-ebs.amd64-web-jammy-php74"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "shell-local" {
    command = "mkdir -p .vendor && berks vendor .vendor"
  }

  provisioner "chef-solo" {
    chef_license   = "accept"
    cookbook_paths = [".vendor"]
    run_list       = ["common", "unattended-upgrades", "useraccounts", "aws_codedeploy", "aws_ssm", "mozjpeg", "web::php74"]
  }

  post-processor "amazon-ami-management" {
    identifier    = "managed"
    keep_releases = "1"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# amd-base-jammy
source "amazon-ebs" "amd64-base-jammy" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-base-jammy_${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "t3a.micro"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-amd64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "amd64_base_jammy"
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

  provisioner "shell-local" {
    command = "mkdir -p .vendor && berks vendor .vendor"
  }

  provisioner "chef-solo" {
    chef_license   = "accept"
    cookbook_paths = [".vendor"]
    run_list       = ["common", "unattended-upgrades", "useraccounts", "aws_codedeploy", "aws_ssm"]
  }

  post-processor "amazon-ami-management" {
    identifier    = "managed"
    keep_releases = "1"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# arm-web-jammy-81
source "amazon-ebs" "arm64-web-jammy-php81" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm-web-jammy-php81_${formatdate("YYYY-MM-DD", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "t4g.micro"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-arm64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "arm64_web_jammy_80"
  }
}
build {
  name    = "arm64-web-jammy-81"
  sources = ["source.amazon-ebs.arm64-web-jammy-php81"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" dist-upgrade",
    ]
  }

  provisioner "shell-local" {
    command = "mkdir -p .vendor && berks vendor .vendor"
  }

  provisioner "chef-solo" {
    chef_license   = "accept"
    cookbook_paths = [".vendor"]
    run_list       = ["common", "unattended-upgrades", "useraccounts", "aws_codedeploy", "aws_ssm", "mozjpeg", "web::php81"]
  }

  post-processor "amazon-ami-management" {
    identifier    = "managed"
    keep_releases = "1"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}

# arm-base-jammy
source "amazon-ebs" "arm64-base-jammy" {
  ami_groups    = ["all"]
  ami_name      = "codemonauts-arm-base-jammy_${formatdate("YYYY-MM-DD-HHmm", timestamp())}"
  ami_regions   = ["eu-west-1"]
  instance_type = "t4g.micro"
  region        = "eu-central-1"
  source_ami    = "${data.amazon-ami.ubuntu-jammy-arm64.id}"
  ssh_username  = "ubuntu"
  tags = {
    Amazon_AMI_Management_Identifier = "arm64_base_jammy"
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

  provisioner "shell-local" {
    command = "mkdir -p .vendor && berks vendor .vendor"
  }

  provisioner "chef-solo" {
    chef_license   = "accept"
    cookbook_paths = [".vendor"]
    run_list       = ["common", "unattended-upgrades", "useraccounts", "aws_codedeploy", "aws_ssm"]
  }

  post-processor "amazon-ami-management" {
    identifier    = "managed"
    keep_releases = "1"
    regions       = ["eu-central-1", "eu-west-1"]
  }
}
