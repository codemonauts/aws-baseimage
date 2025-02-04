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

**arm64**
* Debian Bookworm, Base (codemonauts-arm64-bookworm-base_XXX)
* Debian Bookworm, Webserver with PHP 8.3 (codemonauts-arm64-bookworm-webserver-php83_XXX)

**amd64**
* Debian Bookworm, Base (codemonauts-amd64-bookworm-base_XXX)
* Debian Bookworm, Webserver with PHP 8.3 (codemonauts-amd64-bookworm-webserver-php83_XXX)
