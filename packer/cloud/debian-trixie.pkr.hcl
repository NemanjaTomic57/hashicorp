packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "debian-trixie" {
  filters = {
    virtualization-type = "hvm"
    name                = "debian-13-amd64-*"
    architecture        = "x86_64"
    root-device-type    = "ebs"
  }
  owners      = ["136693071363"]
  most_recent = true
}

source "amazon-ebs" "debian-trixie" {
  region        = "eu-central-1"
  source_ami    = data.amazon-ami.debian-trixie.id
  instance_type = "t2.micro"
  ssh_username  = "admin"
  ami_name      = "packer_debian-trixie_{{timestamp}}"
}

build {
  sources = [
    "source.amazon-ebs.debian-trixie"
  ]

  provisioner "shell" {
    pause_before = "10s"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    scripts = [
      "${path.root}/scripts/install-ssm-agent.sh",
      "${path.root}/scripts/install-docker.sh"
    ]
  }
}
