#
# Cookbook Name:: awesome_customers_ubuntu
# Recipe:: web_user
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
group node['awesome_customers_ubuntu']['group']

user node['awesome_customers_ubuntu']['user'] do
  group node['awesome_customers_ubuntu']['group']
  system true
  shell '/bin/bash'
end
