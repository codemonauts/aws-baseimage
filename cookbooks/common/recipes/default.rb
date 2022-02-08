apt_update 'update' do
  action :update
end

package %w(man-db manpages manpages-dev) do
  action :purge
end

# Install a set of default tools
# Allows easier maintenance via ssh
package 'vim-tiny'
package 'apt-transport-https'
package 'htop'
package 'less'
package 'ncdu'
package 'psmisc'

# Enable systemd-timesyncd to sync with NTP
service 'systemd-timesyncd' do
    action [:enable, :start]
end

# Install locales package and generate en_US and de_DE
package 'locales'

execute "locale-gen" do
  command "locale-gen"
  action :nothing
end

cookbook_file '/etc/locale.gen' do
  source 'locale.gen'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :run, "execute[locale-gen]", :immediate
end

# Install awscli
package "python3-pip";

execute "install awscli" do
  command "pip3 install awscli"
end
