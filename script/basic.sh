#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
# Install GNU time
brew install gnu-time
# Install GNU AWK
brew install gawk
# Install GNU tar
brew install gnu-tar
# Install info command
brew install texinfo
# Install newer less
brew install less
# Install a modern version of Bash.
brew install bash
brew install bash-completion2
# Install modern zsh
brew install zsh

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells; then
    echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
    chsh -s "${BREW_PREFIX}/bin/zsh"
fi

# Install http client tools
brew install wget
brew install curl

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp

# Install search tools
brew install ack
brew install the_silver_searcher
brew install ripgrep

brew install git
brew install git-lfs
brew install diff-so-fancy
brew install gs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install unzip
brew install gzip
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli

brew install llvm

# code indexing tools
brew install global
brew install cscope
brew install universal-ctags

brew install --cask hammerspoon

# Remove outdated versions from the cellar.
brew cleanup
