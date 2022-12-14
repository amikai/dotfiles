#!/usr/bin/env bash

PYENV_LASTEST_VERSION3="$(pyenv latest --known 3)"
PYENV_LASTEST_VERSION2="$(pyenv latest --known 2)"
SYSTEM_CC=/usr/bin/clang

# init pyenv
eval "$(pyenv init -)"

# init venv
eval "$(pyenv virtualenv-init -)"

# install python3
CC=${SYSTEM_CC} pyenv install "$PYENV_LASTEST_VERSION3"

# install python2
CC=${SYSTEM_CC} pyenv install "$PYENV_LASTEST_VERSION2"

pyenv global "$PYENV_LASTEST_VERSION3" "$PYENV_LASTEST_VERSION2"

unset PYENV_LASTEST_VERSION2 PYENV_LASTEST_VERSION3
