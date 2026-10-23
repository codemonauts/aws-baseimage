# AWS-Baseimage

This repository contains the [Ansible](https://www.ansible.com/) cookbooks and the [Packer](https://www.packer.io/) configuration
to generate the AWS AMI, which we use at [codemonauts](https://codemonauts.com/) to start our EC2 instances.

If you find some problems or errors in this repositoy feel free to open an issue or directly fix it with an pull request if you want to.  

## Content
As a basis we choose the latest Debian from the official AWS AMI store. On top of this we did the following for the **base** images:

  * Deactivate the default 'admin' user
  * Create our own 'codemonauts' user with our current SSH public key
  * Activate daily unattended-updates for security patches
  * Install the AWS Codedeploy agent
  * Install the AWS SSM agent
  * Install some basic CLI tools

Additionaly on top for the **webserver** images:
  * Install Nginx and add our config snippets
  * Install mozjpeg for improved JPEG encoding
  * Install PHP-FPM and some PHP Modules which are used by CraftCMS

## Images build by this repo

All images are public and available in eu-central-1 and eu-west-1. The *XXX* in the AMI name is the timestamp during build in the format `YYYY-MM-DD-hh-mm`.

```
codemonauts-<arch>-<codename>-base_XXX
codemonauts-<arch>-<codename>-webserver-php<version>_XXX
```

`<arch>` is `amd64` or `arm64`, `<codename>` is the Debian release, `<version>` is the PHP version without the dot. The defaults live at the top of the `justfile`.

## Prerequisites

 * Allow direnv to run in the cloned repository.

Run `just --list` to see all available recipes.

## Validate

``` shell
just test amd64
just test-all
```

## Build

The webserver image builds on top of the base image, so `just build` creates both in that order:

``` shell
just build                       # asks for the architecture
just build amd64                 # defaults from the justfile
just build amd64 bookworm 8.3    # a different combination
just build-all                   # both architectures
```

## Clean up old AMIs

`just stale-amis` lists AMIs beyond the newest 3 of their family, `just clean-amis` deletes them after you confirm. A family is the AMI name without its timestamp, so every architecture, Debian release and PHP version is counted separately.

An AMI is only offered when it is older than 14 days, is not among the newest 3 of its family, and no launch template version in this account references it. `just build` prints how many could be cleaned up but never deletes anything itself.
