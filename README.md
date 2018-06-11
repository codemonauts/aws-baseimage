# AWS-Baseimage

This repository contains the [Chef]() cookbooks and the [Packer]() configuration to generate the AWS AMI,
which we use at [codemonauts](https://codemonauts.com/) to start our EC2 instances.

If you find some problems or errors in this repositoy feel free to open an issue or directly fix it with an pull
request if you want to.  

## Known problems
* Until the AWS Codedeploy agent is compatible with Ruby 2.5 we can't use Ubuntu 18.04.
  See this [GitHub issue](https://github.com/aws/aws-codedeploy-agent/issues/158) for more informaton.


## Content

As a basis we choose the latest Ubuntu LTS from the official AWS AMI store. On top of this we did the following:

  * Deactivate the default 'ubuntu' user
  * Create our own `codemonauts` user with our current SSH public key
  * Activate dialy unattended-updates for security patches
  * Install Nginx and add our config snippets
  * Install PHP7-FPM and some PHP Modules which are used for CraftCMS
  * Install the AWS Codedeploy agent
  * Install the AWS Cloudwatch agent
  * Activate systemd-timesyncd to get a correct clock
