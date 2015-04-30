#!/bin/sh


# link Emacs.app under Applications
ln -s $(brew --prefix emacs-mac)/Emacs.app ~/Applications

# install spacemacs
git clone --recursive http://github.com/syl20bnr/spacemacs ~/.emacs.d
