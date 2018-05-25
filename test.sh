#! /usr/bin/env bash
set -eu

echo "> Checcking packer.json for errors..."
packer validate packer.json

echo "> Checcking Chef cookbooks for errors..."
foodcritic -f any ./cookbooks
