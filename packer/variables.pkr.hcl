# Ubuntu
variable "ubuntu_boot_command" {
  type = list(string)
  default = [
    "<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu <wait><f10><wait>"
  ]
}

variable "ubuntu_iso_checksum" {
  type    = string
  default = "file:https://www.releases.ubuntu.com/resolute/SHA256SUMS"
}

variable "ubuntu_iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.iso"
}

variable "ubuntu_vm_name" {
  type    = string
  default = "ubuntu"
}

# Debian
variable "debian_boot_command" {
  type = list(string)
  default = [
    "<wait>e<wait><down><down><down><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><f10><wait>"
  ]
}

variable "debian_iso_checksum" {
  type    = string
  default = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
}

variable "debian_iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.5.0-amd64-netinst.iso"
}

variable "debian_vm_name" {
  type    = string
  default = "debian"
}

# Rocky Linux
variable "rockylinux_boot_command" {
  type = list(string)
  default = [
    "<wait><up><wait>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff>"
  ]
}

variable "rockylinux_iso_checksum" {
  type    = string
  default = "file:https://download.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM"
}

variable "rockylinux_iso_url" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.1-x86_64-boot.iso"
}

variable "rockylinux_vm_name" {
  type    = string
  default = "rockylinux"
}
