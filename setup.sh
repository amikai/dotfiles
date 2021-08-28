#!/usr/bin/env bash

. helper.sh
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SHELLS="/private/etc/shells"
IN_CI=${IN_CI:false}

if [ "$IN_CI" = false ] ; then
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
else
    # The user is a sudoer in travis ci, password is not required.
    sudo -n true 
fi

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
success "Homebrew installation success"


brew install stow
mkdir -p "$XDG_CONFIG_HOME"
cd "$DOTFILES_DIR" && stow -t "$HOME" "runcom"
cd "$DOTFILES_DIR" && stow -t "$XDG_CONFIG_HOME" "config"
success "Stow link success"


if ! grep -q "$BASH" "$SHELLS"; then
    brew install bash bash-completion@2
    echo "$BASH" | sudo tee -a "$SHELLS" > /dev/null
    chsh -s "$BASH"
    success "Change shell to newer version ${BASH}"
fi

brew install git git-extras

scripts=(basic.sh exrta.sh python.sh golang.sh nveovim.sh rust.sh)
for script in "${scripts[@]}"; do
    "$BASH" "${DOTFILES_DIR}/script/${script}"
    success "Run ${script} finish"
done
