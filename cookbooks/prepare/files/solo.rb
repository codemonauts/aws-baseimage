Encoding.default_external = Encoding::UTF_8
ENV['LC_ALL'] = 'en_US.UTF-8'

chef_path = "/var/chef"
cookbook_path "#{chef_path}/cookbooks"
file_cache_path "#{chef_path}"
role_path "#{chef_path}/roles"
data_bag_path "#{chef_path}/data_bags"
log_level :info
log_location STDOUT