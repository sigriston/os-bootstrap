#!/bin/sh


# activate pyenv
eval "$(pyenv init -)"

# CFLAGS to properly build python on OS X
CFLAGS="${CFLAGS} -I$(xcrun --show-sdk-path)/usr/include"

# install latest python 2.7 and 3.4
pyenv install 2.7.9
pyenv install 3.4.3
pyenv global 2.7.9

# update pip
pip install -U pip

# install python packages
pip install -U BeautifulSoup
pip install -U Bottleneck
pip install -U Cython
pip install -U docutils
pip install -U GDAL
pip install -U gnureadline
pip install -U ipython
pip install -U jedi
pip install -U Jinja2
pip install -U json-rpc
pip install -U jsonschema
pip install -U m3-dbfpy
pip install -U MarkupSafe
pip install -U matplotlib
pip install -U mistune
pip install -U mock
pip install -U nose
pip install -U numexpr
pip install -U numpy
pip install -U numpydoc
pip install -U pandas
pip install -U ptyprocess
pip install -U pyasn1
pip install -U pycparser
pip install -U Pygments
pip install -U pyparsing
pip install -U python-dateutil
pip install -U pytz
pip install -U pyzmq
pip install -U queuelib
pip install -U rarfile
pip install -U requests
pip install -U scipy
pip install -U service-factory
pip install -U setuptools
pip install -U six
pip install -U Sphinx
pip install -U statsmodels
pip install -U terminado
pip install -U tornado
pip install -U vboxapi
pip install -U xlrd
