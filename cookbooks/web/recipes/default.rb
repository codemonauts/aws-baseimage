include_recipe 'web::ondrej'

package "nginx";
package "nginx-extras";
package "mysql-client"
package "php-imagick";
package "php7.4-soap";
package "php7.4-xml";
package "php7.4-cli";
package "php7.4-curl";
package "php7.4-fpm";
package "php7.4-gd";
package "php7.4-intl";
package "php7.4-mbstring";
package "php7.4-mysql";
package "php7.4-opcache";
package "php7.4-xml";
package "php7.4-zip";

# Delete default configuration files
file_array = ['/etc/nginx/sites-enabled/default',
              '/etc/nginx/sites-available/default',
              '/etc/php/7.4/fpm/pool.d/www.conf']

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

service "php7.4-fpm" do
  action [:stop, :disable]
end

service "nginx" do
  action [:stop, :disable]
end
