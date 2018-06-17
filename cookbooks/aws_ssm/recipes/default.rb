# get AWS Instant Agent
remote_file '/tmp/amazon-ssm-agent.deb' do
  source "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb"
  group 'root'
  owner 'root'
  mode 0644
end

dpkg_package "amazon-ssm-agent" do
  package_name "amazon-ssm-agent"
  source "/tmp/amazon-ssm-agent.deb"
  action :install
end
