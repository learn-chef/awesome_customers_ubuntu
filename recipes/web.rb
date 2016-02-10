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

# Write the home page.
file "#{node['awesome_customers_ubuntu']['document_root']}/index.html" do
  content '<html>This is a placeholder</html>'
  mode '0644'
  owner node['awesome_customers_ubuntu']['user']
  group node['awesome_customers_ubuntu']['group']
end
