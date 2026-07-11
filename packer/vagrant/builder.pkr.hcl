locals {
  common_scripts = [
    "${path.root}/scripts/_common/vagrant.sh",
    "${path.root}/scripts/_common/sshd.sh",
    "${path.root}/scripts/_common/guest_tools_virtualbox.sh",
    "${path.root}/scripts/_common/guest_tools_qemu.sh",
  ]

  nix_environment_vars = ["HOME_DIR=/home/vagrant"]
  nix_execute_command  = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
}

build {
  sources = [
    # "source.qemu.ubuntu",
    # "source.qemu.rockylinux",
    # "source.virtualbox-iso.debian",
    "source.virtualbox-iso.rockylinux",
  ]

  # Linux Shell scripts
  # Install updates and reboot
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/_common/update_packages.sh"]
    valid_exit_codes  = [0, 143]
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }
  # Install build tools and reboot
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/_common/build_tools.sh"]
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }
  # Run common scripts and guest tools installation
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = local.common_scripts
  }
  provisioner "shell" {
    inline = [
      "echo 'Waiting after reboot'"
    ]
    pause_after = "10s"
  }

  post-processor "vagrant" {
    compression_level   = 9
    keep_input_artifact = false
    output              = "${path.root}/builds/vagrant/${var.rockylinux_vm_name}.{{ .Provider }}.box"
  }
}
