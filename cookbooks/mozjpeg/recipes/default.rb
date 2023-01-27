package %w(cmake autoconf automake libtool nasm make pkg-config) do
  action :install
end

cookbook_file '/tmp/installer.sh' do
  source 'installer.sh'
  mode '755'
end

execute 'install my lib' do
  command 'sh /tmp/installer.sh'
end

package %w(cmake autoconf automake libtool nasm make pkg-config) do
  action :purge
end
