#!/bin/sh -e

# pexpect - needed for ansible 'expect' module
pacman -S python-pexpect

ansible-playbook -i hosts playbook.yml
