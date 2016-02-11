#
# Cookbook Name:: awesome_customers_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'apt::default'
include_recipe 'awesome_customers_ubuntu::firewall'
include_recipe 'awesome_customers_ubuntu::web_user'
include_recipe 'awesome_customers_ubuntu::web'
include_recipe 'awesome_customers_ubuntu::database'
