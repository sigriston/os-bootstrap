#!/bin/sh -e

sudo apt install -y ansible
ansible-galaxy install -r roles/requirements.yml
ansible-playbook -i hosts --ask-become-pass playbook.yml
