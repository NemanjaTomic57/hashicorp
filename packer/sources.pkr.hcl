locals {
  # QEMU specific options
  qemu_accelerator    = "kvm"
  qemu_cpu_model      = "host"
  qemu_disk_interface = "virtio"
  qemu_format         = "qcow2"
  qemu_net_device     = "virtio-net"
  qemuargs = [
    ["-device", "virtio-serial"],
    ["-chardev", "socket,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent,server=on,wait=off"],
    ["-device", "virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0"],
  ]

  # QEMU source block common options
  qemu_boot_wait        = "5s"
  qemu_communicator     = "ssh"
  qemu_cpus             = 2
  qemu_disk_size        = "20G"
  qemu_headless         = false
  qemu_http_directory   = "${path.root}/http"
  qemu_memory           = 4096
  qemu_output_directory = "builds"
  qemu_shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -p"
  qemu_ssh_password     = "vagrant"
  qemu_ssh_timeout      = "20m"
  qemu_ssh_username     = "vagrant"
}

# Ubuntu
source "qemu" "ubuntu" {
  # QEMU specific options
  accelerator    = local.qemu_accelerator
  cpu_model      = local.qemu_cpu_model
  disk_interface = local.qemu_disk_interface
  format         = local.qemu_format
  net_device     = local.qemu_net_device
  qemuargs       = local.qemuargs

  # Source block common options
  boot_command     = var.ubuntu_boot_command
  boot_wait        = local.qemu_boot_wait
  communicator     = local.qemu_communicator
  cpus             = local.qemu_cpus
  disk_size        = local.qemu_disk_size
  headless         = local.qemu_headless
  http_directory   = local.qemu_http_directory
  memory           = local.qemu_memory
  output_directory = local.qemu_output_directory
  shutdown_command = local.qemu_shutdown_command
  ssh_password     = local.qemu_ssh_password
  ssh_timeout      = local.qemu_ssh_timeout
  ssh_username     = local.qemu_ssh_username
  iso_checksum     = var.ubuntu_iso_checksum
  iso_url          = var.ubuntu_iso_url
  vm_name          = var.ubuntu_vm_name
}

# Rocky Linux
source "qemu" "rockylinux" {
  # QEMU specific options
  accelerator    = local.qemu_accelerator
  cpu_model      = local.qemu_cpu_model
  disk_interface = local.qemu_disk_interface
  format         = local.qemu_format
  net_device     = local.qemu_net_device
  qemuargs       = local.qemuargs

  # Source block common options
  boot_command     = var.rockylinux_boot_command
  boot_wait        = local.qemu_boot_wait
  communicator     = local.qemu_communicator
  cpus             = local.qemu_cpus
  disk_size        = local.qemu_disk_size
  headless         = local.qemu_headless
  http_directory   = local.qemu_http_directory
  memory           = local.qemu_memory
  output_directory = local.qemu_output_directory
  shutdown_command = local.qemu_shutdown_command
  ssh_password     = local.qemu_ssh_password
  ssh_timeout      = local.qemu_ssh_timeout
  ssh_username     = local.qemu_ssh_username
  iso_checksum     = var.rockylinux_iso_checksum
  iso_url          = var.rockylinux_iso_url
  vm_name          = var.rockylinux_vm_name
}
