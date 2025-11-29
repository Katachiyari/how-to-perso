#!/bin/bash

# Création des dossiers principaux
mkdir -p ansible-nginx-lab/{inventories/{dev,prod},group_vars,playbooks,tests}
mkdir -p ansible-nginx-lab/roles/webserver_role/{tasks,handlers,templates,meta}
mkdir -p ansible-nginx-lab/roles/users_role

# Création des fichiers vides
touch ansible-nginx-lab/ansible.cfg
touch ansible-nginx-lab/.ansible-lint
touch ansible-nginx-lab/pipeline.sh
touch ansible-nginx-lab/inventories/dev/hosts.ini
touch ansible-nginx-lab/inventories/prod/hosts.ini
touch ansible-nginx-lab/group_vars/all_vault.yml
touch ansible-nginx-lab/group_vars/webservers.yml
touch ansible-nginx-lab/group_vars/webservers_prod.yml
touch ansible-nginx-lab/playbooks/site.yml
touch ansible-nginx-lab/playbooks/deploy_nginx.yml
touch ansible-nginx-lab/tests/test_webserver.yml

# Rendre le script pipeline exécutable (anticipation)
chmod +x ansible-nginx-lab/pipeline.sh

echo "✅ Arborescence générée avec succès dans ansible-nginx-lab/"
