#!/bin/sh -e

sudo apt install -y ansible
ansible-playbook -i hosts --ask-become-pass playbook.yml
