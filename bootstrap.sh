#!/bin/sh -e


######################################################################
## - sudo only once
##   code taken from .osx by Mathias Bynens (https://mths.be/osx)

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

######################################################################

# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install homebrew-cask
brew install caskroom/cask/brew-cask

# Install ansible
brew install ansible

# Now run ansible playbook and be happy!
ansible-playbook -i hosts playbook.yml
# pushd "$(dirname $0)/config"
# ./dotfiles.sh
# ./emacs.sh
# ./node.sh
# ./prefs.sh
# ./python.sh
# ./zsh.sh
# ./osx.sh
# popd
