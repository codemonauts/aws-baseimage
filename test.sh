#! /usr/bin/env bash
set -eu

echo "> Checcking packer.json for errors..."
packer validate packer.json

echo "> Checcking Chef cookbooks for errors..."
# Ignore rule FC013 because file_cache_path threw errors and was disbaled
foodcritic -f any -t "~FC013" ./cookbooks
