#!/bin/bash -xeu

vagrant up
ansible-playbook -i ./inventory.yml ./playbook.yml --timeout 10
