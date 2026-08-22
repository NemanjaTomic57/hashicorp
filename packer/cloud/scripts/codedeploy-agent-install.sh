#!/usr/bin/env bash

set -euo pipefail

readonly REGION="${AWS_REGION:-$(curl -fsS http://169.254.169.254/latest/meta-data/placement/region)}"
readonly CODEDEPLOY_BUCKET="aws-codedeploy-${REGION}"
readonly INSTALL_DIR="/tmp/codedeploy-agent"

. /etc/os-release

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

case "${ID}" in
    amzn|rhel)
      if [[ "${ID}" == "amzn" && "${VERSION_ID}" != "2023" ]]; then
        echo "Unsupported Amazon Linux version: ${VERSION_ID}" >&2
        exit 1
      fi

      yum install -y wget

      wget -q "https://${CODEDEPLOY_BUCKET}.s3.${REGION}.amazonaws.com/latestv2/install"
      chmod +x ./install
      ./install auto
      ;;

    ubuntu)
      apt-get update
      apt-get install -y wget

      wget -q "https://${CODEDEPLOY_BUCKET}.s3.${REGION}.amazonaws.com/latestv2/install"
      chmod +x ./install
      ./install auto
      ;;

    debian)
      echo "Skipping OS that does not support CodeDeploy agent: ${PRETTY_NAME}"
      exit 0
      ;;

    *)
      echo "Unsupported operating system: ${PRETTY_NAME}" >&2
      exit 1
      ;;
esac

systemctl enable --now codedeploy-agent

systemctl status codedeploy-agent --no-pager
