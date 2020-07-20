#! /usr/bin/env bash
set -eu

# Install cookstyle
gem install foodcritic

# install packer
PACKER_VERSION="1.6.0"
wget https://releases.hashicorp.com/packer/"$PACKER_VERSION"/packer_"$PACKER_VERSION"_linux_amd64.zip
unzip packer_"$PACKER_VERSION"_linux_amd64.zip
