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
  default = "ubuntu.qcow2"
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
  default = "rockylinux.qcow2"
}
