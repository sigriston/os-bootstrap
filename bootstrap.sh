#!/bin/sh -e

sudo apt install -y python-is-python3
sudo apt install -y ansible
ansible-galaxy collection install -r requirements.yml
ansible-galaxy install -r requirements.yml
ansible-playbook -i hosts -M modules --ask-become-pass playbook.yml
