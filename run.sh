#! /usr/bin/env bash
set -eu

echo "Checking syntax and style"
./test.sh

echo "Checking correct AWS Account"
ACCOUNT_NAME=$(aws iam list-account-aliases --max-items=1 | jq --raw-output ".AccountAliases[0]")
CORRECT_ACCOUNT="codemonauts"

if [ "$ACCOUNT_NAME" != "$CORRECT_ACCOUNT" ]; then
	echo "You are using the wrong AWS user"
	echo "Current: $ACCOUNT_NAME"
	echo "Wanted: $CORRECT_ACCOUNT"
	exit 1
fi

echo "Running packer"
packer build packer.json

echo "Done! Now run: ./post.sh <image-id>"
