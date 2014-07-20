#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

bash "add nginx repo" do
  user 'root'
  code <<-EOC
      rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
          sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/nginx.repo
  EOC
  creates "/etc/yum.repos.d/nginx.repo"
end

package "nginx" do
  action :install
  options "--enablerepo=nginx"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/nginx/conf.d/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[nginx]"  
end
