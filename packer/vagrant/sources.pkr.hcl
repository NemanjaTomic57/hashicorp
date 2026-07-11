locals {
  # qemu
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

  # virtualbox-iso
  vbox_chipset                   = "ich9"
  vbox_firmware                  = "efi"
  vbox_gfx_accelerate_3d         = null
  vbox_gfx_controller            = "vboxsvga"
  vbox_gfx_vram_size             = 33
  vbox_guest_additions_path      = "VBoxGuestAdditions_{{ .Version }}.iso"
  vbox_guest_additions_mode      = "upload"
  vbox_guest_additions_interface = null
  vbox_guest_os_type             = "Oracle_64" # drift from bento original
  vbox_hard_drive_interface      = "virtio"
  vbox_iso_interface             = "virtio"
  vbox_nested_virt               = null
  vbox_nic_type                  = null
  vbox_rtc_time_base             = "UTC"
  vbox_usb                       = false
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
    ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
    ["modifyvm", "{{.Name}}", "--mouse", "usb"],
    ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
  ]
  virtualbox_version_file = ".vbox_version"

  # Source block common
  boot_wait        = "5s"
  communicator     = "ssh"
  cpus             = 2
  disk_size        = 65536
  headless         = false
  http_directory   = "${path.root}/http"
  memory           = 4096
  output_directory = "${path.root}/builds/build_files/packer"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -p"
  ssh_password     = "vagrant"
  ssh_timeout      = "20m"
  ssh_username     = "vagrant"
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
  boot_wait        = local.boot_wait
  communicator     = local.communicator
  cpus             = local.cpus
  disk_size        = local.disk_size
  headless         = local.headless
  http_directory   = local.http_directory
  memory           = local.memory
  output_directory = "${local.output_directory}-ubuntu-qemu"
  shutdown_command = local.shutdown_command
  ssh_password     = local.ssh_password
  ssh_timeout      = local.ssh_timeout
  ssh_username     = local.ssh_username
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
  boot_wait        = local.boot_wait
  communicator     = local.communicator
  cpus             = local.cpus
  disk_size        = local.disk_size
  headless         = local.headless
  http_directory   = local.http_directory
  memory           = local.memory
  output_directory = "${local.output_directory}-rockylinux-qemu"
  shutdown_command = local.shutdown_command
  ssh_password     = local.ssh_password
  ssh_timeout      = local.ssh_timeout
  ssh_username     = local.ssh_username
  iso_checksum     = var.rockylinux_iso_checksum
  iso_url          = var.rockylinux_iso_url
  vm_name          = var.rockylinux_vm_name
}

source "virtualbox-iso" "debian" {
  # QEMU specific options
  chipset                   = local.vbox_chipset
  firmware                  = local.vbox_firmware
  gfx_accelerate_3d         = local.vbox_gfx_accelerate_3d
  gfx_controller            = local.vbox_gfx_controller
  gfx_vram_size             = local.vbox_gfx_vram_size
  guest_additions_path      = local.vbox_guest_additions_path
  guest_additions_mode      = local.vbox_guest_additions_mode
  guest_additions_interface = local.vbox_guest_additions_interface
  guest_os_type             = local.vbox_guest_os_type
  hard_drive_interface      = local.vbox_hard_drive_interface
  iso_interface             = local.vbox_iso_interface
  nested_virt               = local.vbox_nested_virt
  nic_type                  = local.vbox_nic_type
  rtc_time_base             = local.vbox_rtc_time_base
  usb                       = local.vbox_usb
  vboxmanage                = local.vboxmanage
  virtualbox_version_file   = local.virtualbox_version_file
  # Source block common options
  boot_command     = var.debian_boot_command
  boot_wait        = local.boot_wait
  communicator     = local.communicator
  cpus             = local.cpus
  disk_size        = local.disk_size
  headless         = local.headless
  http_directory   = local.http_directory
  memory           = local.memory
  output_directory = "${local.output_directory}-debian-virtualbox"
  shutdown_command = local.shutdown_command
  ssh_password     = local.ssh_password
  ssh_timeout      = local.ssh_timeout
  ssh_username     = local.ssh_username
  iso_checksum     = var.debian_iso_checksum
  iso_url          = var.debian_iso_url
  vm_name          = var.debian_vm_name
}

source "virtualbox-iso" "rockylinux" {
  # QEMU specific options
  chipset                   = local.vbox_chipset
  firmware                  = local.vbox_firmware
  gfx_accelerate_3d         = local.vbox_gfx_accelerate_3d
  gfx_controller            = local.vbox_gfx_controller
  gfx_vram_size             = local.vbox_gfx_vram_size
  guest_additions_path      = local.vbox_guest_additions_path
  guest_additions_mode      = local.vbox_guest_additions_mode
  guest_additions_interface = local.vbox_guest_additions_interface
  guest_os_type             = local.vbox_guest_os_type
  hard_drive_interface      = local.vbox_hard_drive_interface
  iso_interface             = local.vbox_iso_interface
  nested_virt               = local.vbox_nested_virt
  nic_type                  = local.vbox_nic_type
  rtc_time_base             = local.vbox_rtc_time_base
  usb                       = local.vbox_usb
  vboxmanage                = local.vboxmanage
  virtualbox_version_file   = local.virtualbox_version_file
  # Source block common options
  boot_command     = var.rockylinux_boot_command
  boot_wait        = local.boot_wait
  communicator     = local.communicator
  cpus             = local.cpus
  disk_size        = local.disk_size
  headless         = local.headless
  http_directory   = local.http_directory
  memory           = local.memory
  output_directory = "${local.output_directory}-rockylinux-virtualbox"
  shutdown_command = local.shutdown_command
  ssh_password     = local.ssh_password
  ssh_timeout      = local.ssh_timeout
  ssh_username     = local.ssh_username
  iso_checksum     = var.rockylinux_iso_checksum
  iso_url          = var.rockylinux_iso_url
  vm_name          = var.rockylinux_vm_name
}
