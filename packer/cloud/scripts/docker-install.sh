#!/usr/bin/env bash

set -euo pipefail

if [[ ! -r /etc/os-release ]]; then
  echo "Unable to determine operating system."
  exit 1
fi

# shellcheck disable=1091
source /etc/os-release

if [[ "${ID}" != "debian" && "${ID}" != "ubuntu" ]]; then
  echo "Skipping Docker installation: unsupported OS '${ID}'."
  exit 0
fi

echo "Installing Docker on ${PRETTY_NAME}..."

sudo apt update
sudo apt install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
  "https://download.docker.com/linux/${ID}/gpg" \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/${ID}
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
