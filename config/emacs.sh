#!/bin/sh -e


# link Emacs.app under Applications
ln -s $(brew --prefix emacs-mac)/Emacs.app ~/Applications

# install spacemacs
rm -rf ~/.emacs.d
git clone --recursive http://github.com/syl20bnr/spacemacs ~/.emacs.d
