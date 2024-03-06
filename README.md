# AWS-Baseimage

This repository contains the [Ansible](https://www.ansible.com/) cookbooks and the [Packer](https://www.packer.io/) configuration
to generate the AWS AMI, which we use at [codemonauts](https://codemonauts.com/) to start our EC2 instances.

If you find some problems or errors in this repositoy feel free to open an issue or directly fix it with an pull request if you want to.  

## Content
As a basis we choose the latest Ubuntu LTS from the official AWS AMI store. On top of this we did the following for the **base** images:

  * Deactivate the default 'ubuntu' user
  * Create our own 'codemonauts' user with our current SSH public key
  * Activate daily unattended-updates for security patches
  * Install the AWS Codedeploy agent
  * Activate systemd-timesyncd to get a correct clock
  * Install some basic CLI tools

Additionaly on top for the **web** images:
  * Install Nginx and add our config snippets
  * Install PHP-FPM and some PHP Modules which are used by CraftCMS

## Images build by this repo
All images are public and available in eu-central-1 and eu-west-1. The *XXX* in the AMI name is the timestamp during build in the format `YYYY-MM-DD-hh-mm`.

**arm64**
* Ubuntu Jammy, Base (codemonauts-arm-base-jammy_XXX)
* Ubuntu Jammy, Web with PHP 8.3 (codemonauts-arm-web-jammy-php83_XXX)

**amd64**
* Ubuntu Jammy, Base (codemonauts-base-jammy_XXX)
* Ubuntu Jammy, Web with PHP 7.4 (codemonauts-web-jammy-php74_XXX)
