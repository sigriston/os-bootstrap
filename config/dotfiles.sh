#!/bin/sh


# set src directory
mkdir -p ~/src

# clone dotfiles
pushd ~/src
rm -rf dotfiles
git clone https://github.com/sigriston/dotfiles
popd

# link dotfiles
# link .gitconfig
rm -f ~/.gitconfig
ln -s ~/src/dotfiles/git/gitconfig ~/.gitconfig
# link .vimrc, .gvimrc
rm -f ~/.vimrc ~/.gvimrc
ln -s ~/src/dotfiles/vim/vimrc ~/.vimrc
ln -s ~/src/dotfiles/vim/gvimrc ~/.gvimrc
# link .spacemacs
rm -f ~/.spacemacs
ln -s ~/src/dotfiles/spacemacs/spacemacs ~/.spacemacs
