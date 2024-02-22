package 'unattended-upgrades'

cookbook_file '/etc/apt/apt.conf.d/50unattended-upgrades' do
  source '50unattended-upgrades'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/etc/apt/apt.conf.d/10periodic' do
  source '10periodic'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/etc/systemd/system/apt-daily-upgrade.timer' do
  source 'apt-daily-upgrade.timer'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
