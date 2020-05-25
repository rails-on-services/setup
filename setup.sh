#!/usr/bin/env bash

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='macos'
fi

echo $platform

if [[ "$platform" == 'linux' ]]; then

  sudo apt update --yes
  sudo apt install python3-pip --yes
  sudo pip3 install ansible

elif [[ "$platform" == 'macos' ]]; then

  # Install homebrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  # Install ansible
  brew install ansible

fi
