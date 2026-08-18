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

source "amazon-ebs" "al2023_arm64" {
  region     = "eu-central-1"
  source_ami = data.amazon-ami.al2023_arm64.id

  instance_type = "t4g.large"
  ssh_username  = "ec2-user"

  ami_name = "al2023-nat-instance-arm64-{{timestamp}}"
}

build {
  name = "nat-instance"

  sources = ["source.amazon-ebs.al2023_arm64"]

  provisioner "file" {
    source      = "./files/cloudwatch-base.json"
    destination = "/tmp/cloudwatch-base.json"
  }

  provisioner "shell" {
    pause_before    = "10s"
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    scripts = [
      "${path.root}/scripts/cloudwatch-config.sh",
    ]
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/nat-config.sh",
    ]
  }
}
