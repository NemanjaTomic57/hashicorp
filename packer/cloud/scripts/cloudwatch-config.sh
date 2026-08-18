#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Amazon CloudWatch Agent - Automatic Installation
# Supports:
#   - Debian 12 ARM64
#   - RPM-based distributions with dnf
# ============================================================

log() {
  echo
  echo "==> $*"
}

error() {
  echo
  echo "ERROR: $*" >&2
  exit 1
}

# ------------------------------------------------------------
# Determine privilege escalation
# ------------------------------------------------------------

if [[ "${EUID}" != 0 ]]; then
  error "This script must be run as root."
fi

# ------------------------------------------------------------
# DNF-based systems
# ------------------------------------------------------------

if [[ -f "/usr/bin/dnf" ]]; then

  log "Detected DNF-based distribution"

  log "Updating system packages"
  dnf -y upgrade

  log "Installing Amazon CloudWatch Agent"
  dnf -y install amazon-cloudwatch-agent

# ------------------------------------------------------------
# Debian / Ubuntu
# ------------------------------------------------------------

elif [[ -f "/usr/bin/apt-get" ]]; then

  log "Detected APT-based distribution"

  # ========================================================
  # Amazon CloudWatch Agent - Debian ARM64
  # ========================================================

  AGENT_URL="https://amazoncloudwatch-agent.s3.amazonaws.com/debian/arm64/latest/amazon-cloudwatch-agent.deb"
  SIG_URL="https://amazoncloudwatch-agent.s3.amazonaws.com/debian/arm64/latest/amazon-cloudwatch-agent.deb.sig"
  KEY_URL="https://amazon-cloudwatch-agent.s3.amazonaws.com/assets/amazon-cloudwatch-agent.gpg"

  WORK_DIR="/tmp/cloudwatch-agent-install"
  PACKAGE="${WORK_DIR}/amazon-cloudwatch-agent.deb"
  SIGNATURE="${WORK_DIR}/amazon-cloudwatch-agent.deb.sig"
  PUBLIC_KEY="${WORK_DIR}/amazon-cloudwatch-agent.gpg"
  GNUPGHOME="${WORK_DIR}/gnupg"

  EXPECTED_FINGERPRINT="9376 16F3 450B 7D80 6CBD 9725 D581 6730 3B78 9C72"
  EXPECTED_FINGERPRINT_COMPACT="${EXPECTED_FINGERPRINT// /}"

  # --------------------------------------------------------
  # Validate platform
  # --------------------------------------------------------

  if [[ "$(dpkg --print-architecture)" != "arm64" ]]; then
    error "This script requires an ARM64 Debian system."
  fi

  if [[ ! -f /etc/debian_version ]]; then
    error "This script is intended for Debian."
  fi

  # --------------------------------------------------------
  # Install dependencies
  # --------------------------------------------------------

  log "Updating APT package index"
  apt-get update

  log "Installing required packages"
  apt-get install -y \
    ca-certificates \
    wget \
    gnupg

  # --------------------------------------------------------
  # Prepare temporary directory
  # --------------------------------------------------------

  log "Preparing temporary directory"

  rm -rf "${WORK_DIR}"
  mkdir -p "${WORK_DIR}"
  chmod 700 "${WORK_DIR}"

  mkdir -p "${GNUPGHOME}"
  chmod 700 "${GNUPGHOME}"

  export GNUPGHOME

  # --------------------------------------------------------
  # Download AWS public key
  # --------------------------------------------------------

  log "Downloading Amazon CloudWatch Agent public key"

  wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -q \
    -O "${PUBLIC_KEY}" \
    "${KEY_URL}"

  # --------------------------------------------------------
  # Import AWS public key
  # --------------------------------------------------------

  log "Importing AWS public key"

  gpg \
    --batch \
    --import \
    "${PUBLIC_KEY}"

  # --------------------------------------------------------
  # Verify AWS public key fingerprint
  # --------------------------------------------------------

  log "Verifying AWS public key fingerprint"

  ACTUAL_FINGERPRINT="$(
    gpg \
      --batch \
      --with-colons \
      --fingerprint 3B789C72 |
    awk -F: '$1 == "fpr" {print $10; exit}'
  )"

  if [[ "${ACTUAL_FINGERPRINT}" != "${EXPECTED_FINGERPRINT_COMPACT}" ]]; then
    error "AWS public key fingerprint does NOT match.

    Expected:
    ${EXPECTED_FINGERPRINT}

    Actual:
    ${ACTUAL_FINGERPRINT}

    The CloudWatch Agent will NOT be installed."
  fi

  log "AWS public key fingerprint verified"

  # --------------------------------------------------------
  # Download CloudWatch Agent
  # --------------------------------------------------------

  log "Downloading CloudWatch Agent ARM64 Debian package"

  wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -q \
    -O "${PACKAGE}" \
    "${AGENT_URL}"

  # --------------------------------------------------------
  # Download signature
  # --------------------------------------------------------

  log "Downloading CloudWatch Agent package signature"

  wget \
    --https-only \
    --secure-protocol=TLSv1_2 \
    -q \
    -O "${SIGNATURE}" \
    "${SIG_URL}"

  # --------------------------------------------------------
  # Verify package signature
  # --------------------------------------------------------

  log "Verifying CloudWatch Agent package signature"

  if ! gpg \
    --batch \
    --verify \
    "${SIGNATURE}" \
    "${PACKAGE}"; then

    error "CloudWatch Agent package signature verification FAILED.

    The package will NOT be installed."
  fi

  log "CloudWatch Agent package signature verified"

  # --------------------------------------------------------
  # Install package
  # --------------------------------------------------------

  log "Installing CloudWatch Agent"

  dpkg -i "${PACKAGE}"

  # --------------------------------------------------------
  # Verify installation
  # --------------------------------------------------------

  log "Verifying installation"

  if ! dpkg-query \
    -W \
    -f='${Status}' \
    amazon-cloudwatch-agent 2>/dev/null |
    grep -q "install ok installed"; then

    error "CloudWatch Agent installation could not be verified."
  fi

  log "CloudWatch Agent installed successfully"

  # --------------------------------------------------------
  # Cleanup
  # --------------------------------------------------------

  log "Cleaning up temporary files"

  rm -rf "${WORK_DIR}"

else

  error "Unsupported distribution: neither dnf nor apt-get was found."

fi

# ============================================================
# Verify CloudWatch Agent binary
# ============================================================

AGENT="/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent"
AGENT_CTL="/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl"

if [[ ! -x "${AGENT}" ]]; then
  error "CloudWatch Agent binary was not found at ${AGENT}"
fi

if [[ ! -x "${AGENT_CTL}" ]]; then
  error "CloudWatch Agent control utility was not found at ${AGENT_CTL}"
fi

log "CloudWatch Agent version"
${AGENT} -version

# ============================================================
# Fetch and start configuration
# ============================================================

CONFIG="/tmp/cloudwatch-base.json"

if [[ ! -f "${CONFIG}" ]]; then
  error "CloudWatch Agent configuration not found: ${CONFIG}"
fi

log "Loading CloudWatch Agent configuration"

"${AGENT_CTL}" \
  -a fetch-config \
  -m ec2 \
  -s \
  -c "file:${CONFIG}"

log "CloudWatch Agent started successfully"

echo
echo "============================================================"
echo " CloudWatch Agent installation complete"
echo "============================================================"
