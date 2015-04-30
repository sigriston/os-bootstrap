#!/bin/sh


# set src directory
mkdir -p ~/src

# clone dotfiles
pushd ~/src
git clone https://github.com/sigriston/dotfiles
popd

# link dotfiles
# link .gitconfig
ln -s ~/src/dotfiles/git/gitconfig ~/.gitconfig
# link .vimrc, .gvimrc
ln -s ~/src/dotfiles/vim/vimrc ~/.vimrc
ln -s ~/src/dotfiles/vim/gvimrc ~/.gvimrc
# link .spacemacs
ln -s ~/src/dotfiles/spacemacs/spacemacs ~/.spacemacs
