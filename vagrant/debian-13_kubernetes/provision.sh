#!/bin/bash

set -e

ansible-playbook ./ansible.playbook.yml -i ./hosts
ansible-playbook ./ansible.controlplane.yml -i ./hosts
