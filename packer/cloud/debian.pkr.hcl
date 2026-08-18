#######################################
# Required Plugins
#######################################

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

#######################################
# Debian 13 AMIs
#######################################

data "amazon-ami" "debian_trixie_x86_64" {
  owners      = ["136693071363"]
  most_recent = true

  filters = {
    name                = "debian-13-amd64-*"
    architecture        = "x86_64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

data "amazon-ami" "debian_trixie_arm64" {
  owners      = ["136693071363"]
  most_recent = true

  filters = {
    name                = "debian-13-arm64-*"
    architecture        = "arm64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

#######################################
# Build Sources
#######################################

source "amazon-ebs" "debian_trixie_x86_64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_trixie_x86_64.id

  instance_type = "t3.large"
  ssh_username  = "admin"

  ami_name = "debian-trixie-x86_64-{{timestamp}}"
}

source "amazon-ebs" "debian_trixie_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_trixie_arm64.id

  instance_type = "t4g.large"
  ssh_username  = "admin"

  ami_name = "debian-trixie-arm64-{{timestamp}}"
}

#######################################
# Image Build
#######################################

build {
  name = "debian-trixie"

  sources = [
    "source.amazon-ebs.debian_trixie_x86_64",
    "source.amazon-ebs.debian_trixie_arm64",
  ]

  provisioner "shell" {
    pause_before = "10s"

    scripts = [
      "${path.root}/scripts/ssm-agent-installation.sh",
      "${path.root}/scripts/docker-installation.sh",
    ]
  }
}
