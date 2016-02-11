#
# Cookbook Name:: awesome_customers_ubuntu
# Recipe:: web
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
# Install Apache and start the service.
httpd_service 'customers' do
  mpm 'prefork'
  action [:create, :start]
end

# Add the site configuration.
httpd_config 'customers' do
  instance 'customers'
  source 'customers.conf.erb'
  notifies :restart, 'httpd_service[customers]'
end

# Create the document root directory.
directory node['awesome_customers_ubuntu']['document_root'] do
  recursive true
end

# Load the secrets file and the encrypted data bag item that holds the root password.
password_secret = Chef::EncryptedDataBagItem.load_secret(node['awesome_customers_ubuntu']['secret_file'])
password_data_bag_item = Chef::EncryptedDataBagItem.load('database_passwords', 'mysql_customers', password_secret)

# Write the home page.
template "#{node['awesome_customers_ubuntu']['document_root']}/index.php" do
  source 'index.php.erb'
  mode '0644'
  owner node['awesome_customers_ubuntu']['user']
  group node['awesome_customers_ubuntu']['group']
  variables(
    :database_password => password_data_bag_item['admin_password']
  )
end

# Install the mod_php5 Apache module.
httpd_module 'php5' do
  instance 'customers'
end

# Install php5-mysql.
package 'php5-mysql' do
  action :install
  notifies :restart, 'httpd_service[customers]'
end
