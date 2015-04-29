#!/usr/bin/env zsh


# activate nvm
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# install node and iojs, default to iojs
nvm install node
nvm install iojs
nvm alias default iojs

# update npm
npm install -g npm

# install global npm packages
npm install -g babel
npm install -g bower
npm install -g coffee-script
npm install -g coffeelint
npm install -g eslint
npm install -g grunt-cli
npm install -g gulp
npm install -g html2jade
npm install -g jake
npm install -g js-beautify
npm install -g js-yaml
npm install -g js2coffee
npm install -g jsonlint
npm install -g jspm
npm install -g karma-cli
npm install -g less
npm install -g LiveScript
npm install -g nesh
npm install -g npm-check-updates
npm install -g sloc
npm install -g tern
npm install -g yo
