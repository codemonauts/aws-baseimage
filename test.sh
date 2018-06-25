#! /usr/bin/env bash
set -eu

echo "> Checking packer.json for errors..."
# Check if we have a local packer executable in this folder
# Otherwise use the system package
if [ -f "packer" ]; then
	PACKER_BIN="./packer"
else
	PACKER_BIN="packer"
fi
$PACKER_BIN validate packer.json

echo "> Checking Chef cookbooks for errors..."
# Ignore rule FC013 because file_cache_path threw errors and was disbaled
foodcritic -f any -t "~FC013" ./cookbooks
