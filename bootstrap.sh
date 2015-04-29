#!/bin/sh


# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install homebrew bundle & bundle up!
brew tap homebrew/bundle
brew bundle
