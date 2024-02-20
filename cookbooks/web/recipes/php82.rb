include_recipe 'web::ondrej'

package 'nginx'
package 'php8.2-bcmath'
package 'php8.2-cli'
package 'php8.2-curl'
package 'php8.2-fpm'
package 'php8.2-gd'
package 'php8.2-imagick'
package 'php8.2-intl'
package 'php8.2-mbstring'
package 'php8.2-mysql'
package 'php8.2-opcache'
package 'php8.2-soap'
package 'php8.2-xml'
package 'php8.2-zip'

# Delete default configuration files
file_array = ['/etc/nginx/sites-enabled/default',
              '/etc/nginx/sites-available/default',
              '/etc/php/8.2/fpm/pool.d/www.conf']

file_array.each do |this_file|
  file this_file do
    action :delete
  end
end

# CraftCMS specific changes
replace_or_add 'increase max_execution_time' do
  path '/etc/php/8.2/fpm/php.ini'
  pattern 'max_execution_time.*'
  line 'max_execution_time = 120'
end

replace_or_add 'increase memory_limit' do
  path '/etc/php/8.2/fpm/php.ini'
  pattern 'memory_limit.*'
  line 'memory_limit = 256M'
end

replace_or_add 'increase upload size' do
  path '/etc/php/8.2/fpm/php.ini'
  pattern 'upload_max_filesize.*'
  line 'upload_max_filesize = 1024M'
end

replace_or_add 'increase post size' do
  path '/etc/php/8.2/fpm/php.ini'
  pattern 'post_max_size.*'
  line 'post_max_size = 1024M'
end

remote_directory '/etc/nginx/snippets/' do
  source 'snippets'
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

service 'php8.2-fpm' do
  action [:stop, :disable]
end

service 'nginx' do
  action [:stop, :disable]
end
