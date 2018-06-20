package 'unattended-upgrades'

cookbook_file '/etc/apt/apt.conf.d/50unattended-upgrades' do
  source '50unattended-upgrades'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# Disable the own unattented-upgrades timer/service by Ubuntu which where introduced in 16.04
# These run on reboot, and conflict with our chef-solo run because apt is locked
service 'apt-daily.service' do
  action :disable
end

service 'apt-daily.timer' do
  action :disable
end