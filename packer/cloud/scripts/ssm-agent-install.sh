#!/usr/bin/env bash

set -euo pipefail

readonly SSM_AGENT_BASE_URL="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest"
readonly TMP_DIR="/tmp/ssm"

log() {
  printf '[INFO] %s\n' "$*"
}

error() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
      error "This script must be run as root."
  fi
}

detect_architecture() {
  case "$(uname -m)" in
    x86_64)
      DEB_ARCH="debian_amd64"
      RPM_ARCH="linux_amd64"
      ;;

    aarch64)
      DEB_ARCH="debian_arm64"
      RPM_ARCH="linux_arm64"
      ;;

    *)
      error "Unsupported architecture: $(uname -m)"
      ;;
  esac
}

detect_os() {
  if [[ ! -r /etc/os-release ]]; then
    error "/etc/os-release not found."
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  OS_ID="${ID}"
  OS_VERSION="${VERSION_ID:-unknown}"

  log "Detected OS: ${OS_ID} ${OS_VERSION}"
  log "Detected architecture: $(uname -m)"
}

install_debian() {
  local package="${TMP_DIR}/amazon-ssm-agent.deb"
  local url="${SSM_AGENT_BASE_URL}/${DEB_ARCH}/amazon-ssm-agent.deb"

  log "Installing SSM Agent from ${url}"

  mkdir -p "${TMP_DIR}"

  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --output "${package}" \
    "${url}"

  dpkg -i "${package}"
}

install_amazon_linux() {
  local url="${SSM_AGENT_BASE_URL}/${RPM_ARCH}/amazon-ssm-agent.rpm"

  log "Installing SSM Agent from ${url}"

  dnf install \
    --assumeyes \
    "${url}"
}

install_ssm_agent() {
  case "${OS_ID}" in
    debian|ubuntu)
      install_debian
      ;;

    amzn)
      case "${OS_VERSION}" in
        2|2023)
          install_amazon_linux
          ;;

        *)
          error "Unsupported Amazon Linux version: ${OS_VERSION}"
          ;;
      esac
      ;;

    *)
      error "Unsupported operating system: ${OS_ID}"
      ;;
  esac
}

enable_ssm_agent() {
  log "Enabling SSM Agent"

  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent
}

verify_ssm_agent() {
  log "Verifying SSM Agent"

  if ! systemctl is-active --quiet amazon-ssm-agent; then
    systemctl status amazon-ssm-agent --no-pager || true
    error "SSM Agent is not running."
  fi

  log "SSM Agent is running."
}

cleanup() {
  rm -rf "${TMP_DIR}"
}

main() {
  require_root
  detect_architecture
  detect_os

  install_ssm_agent
  enable_ssm_agent
  verify_ssm_agent

  cleanup

  log "Amazon SSM Agent installation completed successfully."
}

main "$@"
