#!/bin/sh -e


# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Python 2 from homebrew
brew install python
brew linkapps python

# Install homebrew-cask
brew tap caskroom/cask

# pexpect - needed for ansible 'expect' module
pip install pexpect

# Install ansible
pip install ansible

# Now run ansible playbook and be happy!
ansible-playbook -i hosts --ask-become-pass playbook.yml
