#!/usr/bin/env bash

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='macos'
fi

echo $platform

if [[ "$platform" == 'linux' ]]; then

  sudo mkfs.ext4 /dev/sdb1
  sudo mount /dev/sdb1 /var/lib/docker
  sudo cat /etc/mtab | grep docker | sudo tee -a /etc/fstab
  sudo sed -i '/vps/d' /etc/fstab

  sudo apt update --yes
  sudo apt install python-pip --yes
  sudo pip install ansible

elif [[ "$platform" == 'macos' ]]; then

  # Install homebrew
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  # Install ansible
  brew install ansible

fi
