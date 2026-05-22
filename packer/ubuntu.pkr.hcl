packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# Ubuntu
# source "qemu" "example" {
#   accelerator      = "kvm"
#   boot_command     = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/<wait><f10><wait>"]
#   boot_wait        = "5s"
#   communicator     = "ssh"
#   cpus             = 2
#   disk_interface   = "virtio"
#   disk_size        = "20G"
#   format           = "qcow2"
#   headless         = false
#   http_directory   = "${path.root}/http/ubuntu"
#   iso_checksum     = "sha256:dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
#   iso_url          = "https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.iso"
#   memory           = 4096
#   net_device       = "virtio-net"
#   output_directory = "builds"
#   shutdown_command = "echo 'password' | sudo -S shutdown -P now"
#   ssh_password     = "password"
#   ssh_timeout      = "20m"
#   ssh_username     = "nemo"
#   vm_name          = "ubuntu.qcow2"
# }

# Rockylinux
source "qemu" "example" {
  accelerator = "kvm"
  # boot_command     = ["<wait><up><wait>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff>"]
  boot_wait        = "5s"
  communicator     = "ssh"
  cpus             = 2
  disk_interface   = "virtio"
  disk_size        = "20G"
  format           = "qcow2"
  headless         = false
  http_directory   = "${path.root}/http/rhel"
  iso_checksum     = "file:https://download.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM"
  iso_url          = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.1-x86_64-boot.iso"
  memory           = 4096
  net_device       = "virtio-net"
  output_directory = "builds"
  shutdown_command = "echo 'password' | sudo -S /sbin/halt -p"
  ssh_password     = "password"
  ssh_timeout      = "20m"
  ssh_username     = "nemo"
  vm_name          = "rockylinux.qcow2"
}

build {
  sources = ["source.qemu.example"]
}
