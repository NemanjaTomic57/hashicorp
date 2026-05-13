#!/bin/bash

set -e

cd ansible

ansible-playbook kubeadm-install.yml -i hosts
ansible-playbook controlplanes-config.yml -i hosts
