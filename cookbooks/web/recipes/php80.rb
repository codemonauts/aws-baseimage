include_recipe 'web::ondrej'

package "nginx";
package "mysql-client"
package "php8.0-cli";
package "php8.0-curl";
package "php8.0-fpm";
package "php8.0-gd";
package "php8.0-imagick";
package "php8.0-intl";
package "php8.0-mbstring";
package "php8.0-mysql";
package "php8.0-opcache";
package "php8.0-soap";
package "php8.0-xml";
package "php8.0-zip";

# Delete default configuration files
file_array = ['/etc/nginx/sites-enabled/default',
              '/etc/nginx/sites-available/default',
              '/etc/php/8.0/fpm/pool.d/www.conf']

file_array.each do |this_file|
  file this_file do
    action :delete
  end
end

remote_directory '/etc/nginx/snippets/' do
  source "snippets"
  files_owner 'root'
  files_group 'root'
  owner 'root'
  group 'root'
  purge true
end

cookbook_file '/etc/php/8.0/fpm/php.ini' do
  source 'fpm/php80.ini'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service "php8.0-fpm" do
  action [:stop, :disable]
end

service "nginx" do
  action [:stop, :disable]
end
