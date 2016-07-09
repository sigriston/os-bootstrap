#!/bin/sh -e


# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install homebrew-cask
brew tap caskroom/cask

# Install ansible
brew install ansible

# Now run ansible playbook and be happy!
ansible-playbook -i hosts --ask-become-pass playbook.yml
