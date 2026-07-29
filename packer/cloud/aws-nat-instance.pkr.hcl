packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "al2023" {
  owners      = ["137112412989"]
  most_recent = true

  filters = {
    name                = "al2023-ami-2023*"
    architecture        = "arm64"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
}

source "amazon-ebs" "al2023" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.al2023.id

  instance_type = "t4g.large"
  ssh_username  = "ec2-user"

  ami_name = "al2023-nat-instance-arm64-{{timestamp}}"
}

build {
  name = "nat-instance"

  sources = [
    "source.amazon-ebs.al2023",
  ]

  provisioner "shell" {
    pause_before = "10s"

    scripts = [
      "${path.root}/scripts/configure-nat-instance.sh"
    ]
  }
}
