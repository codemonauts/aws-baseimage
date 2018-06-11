apt_update 'update'

# Install a set of default tools
# Allows easier meintenace via ssh
package 'tmux'
package 'vim'
package 'apt-transport-https'
package 'htop'
package 'less'
package 'ncdu'
package 'psmisc'
package 'tree'

# Enable systemd-timesyncd to sync with NTP
service 'systemd-timesyncd' do
    action [:enable, :start]
  end