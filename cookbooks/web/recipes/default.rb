include_recipe 'web::ondrej'

# Delete default configuration files
file_array = ['/etc/nginx/sites-enables/default',
              '/etc/nginx/sites-available/default',
              '/etc/php/7.4/fpm/pool.d/www.conf']

file_array.each do |this_file|
  file this_file do
    action :delete
  end
end


service "php7.4-fpm" do
  action [:stop, :disable]
end

service "nginx" do
  action [:stop, :disable]
end
