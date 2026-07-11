packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

locals {
  environment_vars = ["HOME_DIR=/home/ntomic"]
  execute_command  = "echo 'password' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
}

source "qemu" "rockylinux10" {
  accelerator    = "kvm"
  cpu_model      = "host"
  disk_interface = "virtio"
  format         = "qcow2"
  net_device     = "virtio-net"
  qemuargs = [
    ["-device", "virtio-serial"],
    ["-chardev", "socket,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent,server=on,wait=off"],
    ["-device", "virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0"],
  ]
  boot_command     = ["<wait><up><wait>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff>"]
  boot_wait        = "5s"
  communicator     = "ssh"
  cpus             = 4
  disk_size        = 65536
  headless         = false
  http_directory   = "${path.root}/http"
  memory           = 4096
  output_directory = "${path.root}/builds/build_files/packer-rockylinux-qemu"
  shutdown_command = "echo 'ntomic' | sudo -S /sbin/halt -p"
  ssh_password     = "password"
  ssh_timeout      = "20m"
  ssh_username     = "ntomic"
  iso_checksum     = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.2-x86_64-boot.iso"
  iso_url          = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.2-x86_64-boot.iso.CHECKSUM"
  vm_name          = "rockylinux10"
}

build {
  sources = ["source.qemu.rockylinux10"]

  provisioner "shell" {
    environment_vars  = local.environment_vars
    execute_command   = local.execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/update_packages.sh"]
    valid_exit_codes  = [0, 143]
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }

  provisioner "shell" {
    environment_vars  = local.environment_vars
    execute_command   = local.execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/build_tools.sh"]
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }

  provisioner "shell" {
    environment_vars  = local.environment_vars
    execute_command   = local.execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/sshd.sh", "${path.root}/scripts/guest_tools_qemu.sh"]
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }
}
