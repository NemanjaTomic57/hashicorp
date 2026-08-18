#!/usr/bin/env bash
set -euo pipefail

# Installing iptables services
sudo dnf install -y iptables-services net-tools

# Enabling iptables service
sudo systemctl enable iptables
sudo systemctl start iptables

# Enabling IP forwarding
sudo tee /etc/sysctl.d/10-ip-forwarding.conf >/dev/null <<EOF
net.ipv4.ip_forward=1
EOF

sudo sysctl --system

# Detecting primary network interface
PRIMARY_IFACE=$(ip route | awk '/default/ {print $5; exit}')

if [[ -z "${PRIMARY_IFACE}" ]]; then
  echo "Failed to determine primary network interface."
  exit 1
fi

echo "Primary interface: ${PRIMARY_IFACE}"

# Remove any existing MASQUERADE rule to avoid duplicates
sudo iptables -t nat -D POSTROUTING -o "${PRIMARY_IFACE}" -j MASQUERADE 2>/dev/null || true

# Configuring iptables NAT
sudo iptables -t nat -A POSTROUTING -o "${PRIMARY_IFACE}" -j MASQUERADE

# Reset forwarding rules
sudo iptables -F FORWARD

# Saving iptables rules
sudo service iptables save

echo "==> NAT configuration complete"
