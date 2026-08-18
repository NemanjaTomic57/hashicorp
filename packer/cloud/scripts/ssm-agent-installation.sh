#!/bin/bash -xeu

case "$(uname -m)" in
  x86_64)
    ARCH="debian_amd64"
    ;;
  aarch64)
    ARCH="debian_arm64"
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac

mkdir /tmp/ssm
cd /tmp/ssm

wget "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/${ARCH}/amazon-ssm-agent.deb"

sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
