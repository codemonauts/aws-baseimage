init:
	packer init packer.pkr.hcl

test: init
	packer validate packer.pkr.hcl
	ansible-lint

build: test
	packer build packer.pkr.hcl

all: build
