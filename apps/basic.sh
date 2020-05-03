#!/usr/bin/env bash

brew tap buo/cask-upgrade
brew tap homebrew/cask-fonts
brew tap homebrew/cask-versions

# Mac App Store command line
brew install mas
mas install 497799835  # Xcode (11.4.1)

brew cask install font-fira-code
brew cask install google-chrome
brew cask install visual-studio-code
brew cask install iterm2
