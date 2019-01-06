#!/bin/sh -e

ansible-playbook -i hosts --ask-become-pass playbook.yml
