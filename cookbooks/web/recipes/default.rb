package "nginx";
package "nginx-extras";
package "php-imagick";
package "php-memcached";
package "php-soap";
package "php-xml";
package "php7.0-cli";
package "php7.0-curl";
package "php7.0-fpm";
package "php7.0-gd";
package "php7.0-intl";
package "php7.0-mbstring";
package "php7.0-mcrypt";
package "php7.0-mysql";
package "php7.0-opcache";
package "php7.0-xml";

# Delete default configuration files
file_array = ['/etc/nginx/sites-enables/default',
              '/etc/nginx/sites-available/default']

file_array.each do |this_file|
  file this_file do
    action :delete
  end
end

# Install aws-elasticache plugin
cookbook_file '/usr/lib/php/20151012/amazon-elasticache-cluster-client.so' do
  source 'amazon-elasticache-cluster-client.so'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

file '/etc/php/7.0/mods-available/aws-memcache.ini' do
  content 'extension=amazon-elasticache-cluster-client.so'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

execute 'enable aws-memcache module' do
  command 'phpenmod aws-memcache'
  action :run
end
