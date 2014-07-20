# Set up redis sentinel
# 
include_recipe 'sudo::default'

user "redis" do
  action :modify
  shell "/bin/bash"
end

service "redis-sentinel" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/var/lib/redis/failover.sh" do
  source "failover.sh.erb"
  owner "redis"
  group "root"
  mode 0755
  notifies :restart, "service[redis]"  
  notifies :restart, "service[redis-sentinel]"  
end

template "/etc/redis-sentinel.conf" do
  source "redis-sentinel.conf.erb"
  owner "redis"
  group "root"
  mode 0644
  notifies :restart, "service[redis]"  
  notifies :restart, "service[redis-sentinel]"  
end

template "/var/lib/redis/set_vip.sh" do
  source "set_vip.sh.erb"
  owner "redis"
  group "root"
  mode 0755
  notifies :restart, "service[redis]"  
  notifies :restart, "service[redis-sentinel]"  
end

template "/etc/init.d/redis" do
  source "redis_service.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, "service[redis]"  
  notifies :restart, "service[redis-sentinel]"  
end

# 手動フェイルオーバスクリプト配置
template "/var/lib/redis/manual_failover.sh" do
  source "manual_failover.sh.erb"
  owner "redis"
  group "root"
  mode 0755
end

