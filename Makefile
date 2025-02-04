init:
	packer init baseimage.pkr.hcl
	packer init webserver.pkr.hcl

test: init
	packer validate baseimage.pkr.hcl
	packer validate webserver.pkr.hcl
	ansible-lint

build: test
	packer build baseimage.pkr.hcl
	packer build webserver.pkr.hcl

all: build
