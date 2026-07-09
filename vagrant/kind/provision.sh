#!/bin/bash -xeu

vagrant up
ansible-playbook -i ./inventory.yml ./k8s-cluster-creation.yml --timeout 30
ansible-playbook -i ./inventory.yml ./k8s-configuration.yml
