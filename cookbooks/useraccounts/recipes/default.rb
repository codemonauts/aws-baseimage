user 'cmonauts' do
  comment 'Admin account'
  home '/home/cmonauts'
  manage_home true
  shell '/bin/bash'
  password '$6$YSDsU/ZetJlqs$f26S1INvF4a1hFpc4VQa4vWodqF55ZTV4EZtoxKyXd1wF/sN.pT/AGo3t86FNpegeevdohn4DVL4CCs45z43Z.'
  action :create
end

directory '/home/cmonauts/.ssh' do
  owner 'cmonauts'
  group 'cmonauts'
  mode '0700'
  action :create
end

cookbook_file '/home/cmonauts/.ssh/authorized_keys' do
  source 'authorized_keys'
  owner 'cmonauts'
  group 'cmonauts'
  mode '0600'
  action :create
end

# Passwordless sudo for user cmonauts
package 'sudo'

cookbook_file "/etc/sudoers.d/90-cmonauts" do
  source "sudoers"
  mode 0440
  owner "root"
  group "root"
end

# Disable password login for ubuntu user
user 'ubuntu' do
  password '!'
  action :modify
end

execute 'disable ubuntu user' do
  command 'usermod --expiredate 1 ubuntu'
  action :run
end
