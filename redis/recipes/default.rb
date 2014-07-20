#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "add remi repo" do
  user 'root'
  code <<-EOC
      rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
          sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi.repo
  EOC
  creates "/etc/yum.repos.d/remi.repo"
end

package "redis" do
  action :install
  options "--enablerepo=remi"
end

service "redis" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/redis.conf" do
  source "redis.conf.erb"
  owner "redis"
  group "root"
  mode 0644
  notifies :restart, "service[redis]"  
end
