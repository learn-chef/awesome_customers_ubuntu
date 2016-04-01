#
# Cookbook Name:: awesome_customers_ubuntu
# Recipe:: database
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
mysql2_chef_gem 'default' do
  action :install
end

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

# Load the secrets file and the encrypted data bag item that holds the root password.
password_secret = Chef::EncryptedDataBagItem.load_secret(node['awesome_customers_ubuntu']['secret_file'])
password_data_bag_item = Chef::EncryptedDataBagItem.load('database_passwords', 'mysql_customers', password_secret)

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password password_data_bag_item['root_password']
  action [:create, :start]
end

# Create the database instance.
mysql_database node['awesome_customers_ubuntu']['database']['dbname'] do
  connection(
    :host => node['awesome_customers_ubuntu']['database']['host'],
    :username => node['awesome_customers_ubuntu']['database']['root_username'],
    :password => password_data_bag_item['root_password']
  )
  action :create
end

# Add a database user.
mysql_database_user node['awesome_customers_ubuntu']['database']['admin_username'] do
  connection(
    :host => node['awesome_customers_ubuntu']['database']['host'],
    :username => node['awesome_customers_ubuntu']['database']['root_username'],
    :password => password_data_bag_item['root_password']
  )
  password password_data_bag_item['admin_password']
  database_name node['awesome_customers_ubuntu']['database']['dbname']
  host node['awesome_customers_ubuntu']['database']['host']
  action [:create, :grant]
end

# Write schema seed file to filesystem.
cookbook_file node['awesome_customers_ubuntu']['database']['create_tables_script'] do
  source 'create-tables.sql'
  owner 'root'
  group 'root'
  mode '0600'
end

# Seed the database with a table and test data.
execute "initialize #{node['awesome_customers_ubuntu']['database']['dbname']} database" do
  command "mysql -h #{node['awesome_customers_ubuntu']['database']['host']} -u #{node['awesome_customers_ubuntu']['database']['admin_username']} -p#{password_data_bag_item['admin_password']} -D #{node['awesome_customers_ubuntu']['database']['dbname']} < #{node['awesome_customers_ubuntu']['database']['create_tables_script']}"
  not_if  "mysql -h #{node['awesome_customers_ubuntu']['database']['host']} -u #{node['awesome_customers_ubuntu']['database']['admin_username']} -p#{password_data_bag_item['admin_password']} -D #{node['awesome_customers_ubuntu']['database']['dbname']} -e 'describe customers;'"
end
