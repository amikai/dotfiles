#!/usr/bin/env bash

PYENV_LASTEST_VERSION3=$(pyenv install --list | tr -d ' ' | grep '^3.[0-9].[0-9]$' | tail -1)

PYENV_LASTEST_VERSION2=$(pyenv install --list | tr -d ' ' | grep '^2.[0-9].[0-9]$' | tail -1)

# init pyenv
eval "$(pyenv init -)"

# init venv
eval "$(pyenv virtualenv-init -)"

# install python2
pyenv install "$PYENV_LASTEST_VERSION2"

# install python3
pyenv shell "$PYENV_LASTEST_VERSION2" "$PYENV_LASTEST_VERSION3"

unset PYENV_LASTEST_VERSION2 PYENV_LASTEST_VERSION3
