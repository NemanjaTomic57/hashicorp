#######################################
# Plugins
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
# Data Block
#######################################

data "amazon-ami" "al2023_arm64" {
  owners      = ["137112412989"]
  most_recent = true

  filters = {
    name                = "al2023-ami-2023*"
    architecture        = "arm64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

data "amazon-ami" "debian_bookworm_x86_64" {
  owners      = ["136693071363"]
  most_recent = true

  filters = {
    name                = "debian-12-amd64-*"
    architecture        = "x86_64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

data "amazon-ami" "debian_bookworm_arm64" {
  owners      = ["136693071363"]
  most_recent = true

  filters = {
    name                = "debian-12-arm64-*"
    architecture        = "arm64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

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

data "amazon-ami" "ubuntu_noble_arm64" {
  owners      = ["099720109477"]
  most_recent = true

  filters = {
    name                = "ubuntu/images/*/ubuntu-noble-24.04-*"
    architecture        = "arm64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

#######################################
# Source Block
#######################################

source "amazon-ebs" "al2023_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.al2023_arm64.id

  instance_type = "t4g.medium"
  ssh_username  = "ec2-user"

  ami_name = "al2023-nat-instance-arm64-{{timestamp}}"
}

source "amazon-ebs" "debian_bookworm_x86_64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_bookworm_x86_64.id

  instance_type = "t3.medium"
  ssh_username  = "admin"

  ami_name = "debian-bookworm-x86_64-{{timestamp}}"
}

source "amazon-ebs" "debian_bookworm_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_bookworm_arm64.id

  instance_type = "t4g.medium"
  ssh_username  = "admin"

  ami_name = "debian-bookworm-arm64-{{timestamp}}"
}

source "amazon-ebs" "debian_trixie_x86_64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_trixie_x86_64.id

  instance_type = "t3.medium"
  ssh_username  = "admin"

  ami_name = "debian-trixie-x86_64-{{timestamp}}"
}

source "amazon-ebs" "debian_trixie_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.debian_trixie_arm64.id

  instance_type = "t4g.medium"
  ssh_username  = "admin"

  ami_name = "debian-trixie-arm64-{{timestamp}}"
}

source "amazon-ebs" "ubuntu_noble_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.ubuntu_noble_arm64.id

  instance_type = "t4g.medium"
  ssh_username  = "ubuntu"

  ami_name = "ubuntu-noble-arm64-{{timestamp}}"
}

#######################################
# Build Block
#######################################

locals {
  execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
}

build {
  sources = [
    "source.amazon-ebs.al2023_arm64",
    "source.amazon-ebs.debian_bookworm_arm64",
    "source.amazon-ebs.ubuntu_noble_arm64"
  ]

  provisioner "file" {
    source      = "./files/cloudwatch-base.json"
    destination = "/tmp/cloudwatch-base.json"
  }

  provisioner "shell" {
    pause_before    = "10s"
    execute_command = local.execute_command
    scripts = [
      "${path.root}/scripts/cloudwatch-config.sh",
      "${path.root}/scripts/ssm-agent-install.sh",
      "${path.root}/scripts/codedeploy-agent-install.sh",
      "${path.root}/scripts/docker-install.sh",
    ]
  }

  provisioner "shell" {
    scripts = ["${path.root}/scripts/nat-config.sh"]
  }
}
