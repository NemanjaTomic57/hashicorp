#!/usr/bin/env bash
# Installs the SSM Agent on Amazon Linux 2023 and Debian

set -euo pipefail

SSM_AGENT_BASE_URL="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest"
TMP_DIR="/tmp/ssm"

if [[ "${EUID}" -ne 0 ]]; then
  printf '[ERROR] This script must be run as root.\n' >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  printf '[ERROR] /etc/os-release not found.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

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
    printf '[ERROR] Unsupported architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p "${TMP_DIR}"

if [[ "${ID}" == "amzn" ]]; then

  if [[ "${VERSION_ID}" != "2023" ]]; then
    printf '[ERROR] Unsupported Amazon Linux version: %s\n' "${VERSION_ID}" >&2
    exit 1
  fi

  URL="${SSM_AGENT_BASE_URL}/${RPM_ARCH}/amazon-ssm-agent.rpm"

  dnf install \
    --assumeyes \
    "${URL}"

elif [[ "${ID}" == "debian" ]]; then

  PACKAGE="${TMP_DIR}/amazon-ssm-agent.deb"
  URL="${SSM_AGENT_BASE_URL}/${DEB_ARCH}/amazon-ssm-agent.deb"

  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --output "${PACKAGE}" \
    "${URL}"

  dpkg -i "${PACKAGE}"

else
  printf '[INFO] Unsupported operating system: %s\n' "${ID}"
  exit 0
fi

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

if ! systemctl is-active --quiet amazon-ssm-agent; then
  systemctl status amazon-ssm-agent --no-pager || true
  printf '[ERROR] SSM Agent is not running.\n' >&2
  exit 1
fi

rm -rf "${TMP_DIR}"

printf '[INFO] Amazon SSM Agent installation completed successfully.\n'
