#!/bin/sh


# set src directory
mkdir -p ~/src

# clone dotfiles
pushd ~/src
git clone https://github.com/sigriston/dotfiles
popd
