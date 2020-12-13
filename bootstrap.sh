#!/bin/sh -e

sudo apt install -y ansible
ansible-galaxy collection install -r requirements.yml
ansible-galaxy install -r requirements.yml
ansible-playbook -i hosts --ask-become-pass playbook.yml
