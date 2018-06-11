# dependencys for the Codedeploy agent
package 'ruby'

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
