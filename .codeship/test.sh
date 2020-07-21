#! /usr/bin/env bash
set -eu

echo "> Checking packer.json for errors..."
for CONF in $(ls packer-*.json); do ./packer validate -syntax-only $CONF; done

echo "> Checking Chef cookbooks for errors..."
# Ignore
# FC011 Missing README
# FC013 because file_cache_path threw errors and was disbaled
# FC064 No issues-url in metadata
# FC065 No source-url in metadata
# FC064 No chef-version in metadata
# FC069 Standardized license
# FC071 Missing LICENSE
# FC078 Ensure OSI-approved LICENSE

foodcritic -f any -t "~FC011" -t "~FC013" -t "~FC064"  -t "~FC065" -t "~FC066" -t "~FC069" -t "~FC071" -t "~FC078" ./cookbooks
