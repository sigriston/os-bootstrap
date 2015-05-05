#!/bin/sh -e


# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install homebrew bundle & bundle up!
brew tap homebrew/bundle
brew bundle

# Now run config scripts
pushd "$(dirname $0)/config"
./dotfiles.sh
./emacs.sh
./node.sh
./prefs.sh
./python.sh
./zsh.sh
./osx.sh
popd
