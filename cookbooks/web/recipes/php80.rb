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

# CraftCMS specific changes
replace_or_add "increase max_execution_time" do
  path "/etc/php/8.0/fpm/php.ini"
  pattern "max_execution_time.*"
  line "max_execution_time = 120"
end

replace_or_add "increase memory_limit" do
  path "/etc/php/8.0/fpm/php.ini"
  pattern "memory_limit.*"
  line "memory_limit = 256M"
end

remote_directory '/etc/nginx/snippets/' do
  source "snippets"
  files_owner 'root'
  files_group 'root'
  owner 'root'
  group 'root'
  purge true
end

service "php8.0-fpm" do
  action [:stop, :disable]
end

service "nginx" do
  action [:stop, :disable]
end
