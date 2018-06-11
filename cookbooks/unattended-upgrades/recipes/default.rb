package 'unattended-upgrades'

cookbook_file '/etc/apt/apt.conf.d/50unattended-upgrades' do
  source '50unattended-upgrades'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
