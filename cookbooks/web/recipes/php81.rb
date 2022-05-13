include_recipe 'web::ondrej'

package "nginx";
package "mysql-client"
package "php8.1-bcmath";
package "php8.1-cli";
package "php8.1-curl";
package "php8.1-fpm";
package "php8.1-gd";
package "php8.1-imagick";
package "php8.1-intl";
package "php8.1-mbstring";
package "php8.1-mysql";
package "php8.1-opcache";
package "php8.1-soap";
package "php8.1-xml";
package "php8.1-zip";

# Delete default configuration files
file_array = ['/etc/nginx/sites-enabled/default',
              '/etc/nginx/sites-available/default',
              '/etc/php/8.1/fpm/pool.d/www.conf']

file_array.each do |this_file|
  file this_file do
    action :delete
  end
end

# CraftCMS specific changes
replace_or_add "increase max_execution_time" do
  path "/etc/php/8.1/fpm/php.ini"
  pattern "max_execution_time.*"
  line "max_execution_time = 120"
end

replace_or_add "increase memory_limit" do
  path "/etc/php/8.1/fpm/php.ini"
  pattern "memory_limit.*"
  line "memory_limit = 256M"
end

replace_or_add "increase upload size" do
  path "/etc/php/8.1/fpm/php.ini"
  pattern "upload_max_filesize.*"
  line "upload_max_filesize = 1024M"
end

replace_or_add "increase post size" do
  path "/etc/php/8.1/fpm/php.ini"
  pattern "post_max_size.*"
  line "post_max_size = 1024M"
end

remote_directory '/etc/nginx/snippets/' do
  source "snippets"
  files_owner 'root'
  files_group 'root'
  owner 'root'
  group 'root'
  purge true
end

cookbook_file '/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

service "php8.1-fpm" do
  action [:stop, :disable]
end

service "nginx" do
  action [:stop, :disable]
end
