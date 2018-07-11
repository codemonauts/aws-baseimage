# dependencys for the Codedeploy agent
package 'ruby'
package 'gdebi-core'

remote_file '/tmp/codedeploy-installer' do
  source 'https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/install'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'install-coddeploy' do
  command '/tmp/codedeploy-installer auto'
  action :run
end

service 'codedeploy-agent' do
  action [:start, :enable]
end

# Deploy a custom cron script to get rid of the "@reboot" job
cookbook_file '/etc/cron.d/codedeploy-agent-update' do
  source 'codedeploy-agent-update'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end