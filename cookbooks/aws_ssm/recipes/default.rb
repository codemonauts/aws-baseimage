if node['cpu']['architecture']== "aarch64"
  remote_file '/tmp/ssm.deb' do
    source 'https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
elsif node['cpu']['architecture'] == "x86_64"
  remote_file '/tmp/ssm.deb' do
    source 'https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

execute 'install ssm agent' do
  command 'dpkg -i /tmp/ssm.deb'
  action :run
end

service 'amazon-ssm-agent' do
  action [:start, :enable]
end
