#!/bin/sh


# config /etc/shells to use homebrew zsh
sudo sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells'

# clone prezto
git clone --recursive https://github.com/sigriston/prezto ~/.zprezto

# clone zsh-notify
git clone https://github.com/marzocchi/zsh-notify ~/.zsh-notify

# link prezto
ln -s ~/.zprezto/runcoms/zlogin ~/.zlogin
ln -s ~/.zprezto/runcoms/zlogout ~/.zlogout
ln -s ~/.zprezto/runcoms/zpreztorc ~/.zpreztorc
ln -s ~/.zprezto/runcoms/zprofile ~/.zprofile
ln -s ~/.zprezto/runcoms/zshenv ~/.zshenv
ln -s ~/.zprezto/runcoms/zshrc ~/.zshrc

# set zsh as default shell
chsh -s /usr/local/bin/zsh
