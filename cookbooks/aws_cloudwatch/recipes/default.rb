
remote_file '/tmp/cloudwatch-installer.py' do
  source 'https://s3.amazonaws.com//aws-cloudwatch/downloads/latest/awslogs-agent-setup.py'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/awslogs/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/etc/awslogs/cwlogs.cfg' do
  source 'cwlogs.cfg'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end


execute 'install-cloudwatch' do
  command '/tmp/cloudwatch-installer.py -n -r eu-central-1 -c /etc/awslogs/cwlogs.cfg'
  action :run
end

service 'codedeploy-agent' do
  action [:start, :enable]
end
