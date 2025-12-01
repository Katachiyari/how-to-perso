#!/bin/bash
set -e

echo "Running Ansible Syntax Check..."
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check

echo "Running Ansible Playbook..."
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml

echo "Running Tests..."
ansible-playbook -i inventories/dev/hosts.ini tests/test_webserver.yml
