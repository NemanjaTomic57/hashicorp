#!/usr/bin/env bash

set -eu

vagrant up
ansible-playbook -i inventory.yml playbook.yml
