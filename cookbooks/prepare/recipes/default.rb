cookbook_file "/usr/local/bin/prepare.sh" do
  source "prepare.sh"
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "/etc/systemd/system/chef-solo.service" do
  source "chef-solo.service"
  mode 0664
  owner "root"
  group "root"
end

directory '/var/chef' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/var/chef/solo.rb" do
  source "solo.rb"
  mode 0664
  owner "root"
  group "root"
end

service "chef-solo.service" do
  action [:enable]
end
