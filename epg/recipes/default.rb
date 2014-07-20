#
# Cookbook Name:: epg
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# カードリーダ用パッケージをインストール
#
%w{ccid pcsc-lite pcsc-lite-devel pcsc-lite-libs}.each do |pkg|
  package pkg do
    action :install
  end
end

bash 'add_rpmforge' do
  user 'root'
  code <<-EOC
          rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
              sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/rpmforge.repo
  EOC
  creates "/etc/yum.repos.d/rpmforge.repo"
end

package "perl-Gtk2" do
  action :install
  options "--enablerepo=rpmforge"
end

%w{pcsc-perl-1.4.8-2.fc13.x86_64.rpm pcsc-tools-1.4.16-1.fc13.x86_64.rpm }.each do |pkg|
  dir = "/usr/local/src/"
  cookbook_file "#{dir}#{pkg}" do
    source pkg
  end

  rpm_package pkg do
    source "#{dir}#{pkg}"
    action :install
  end
end

service "pcscd" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end


#
# arib25(放送波のデコード)のインストール
#
%w{arib25-20140524-1.x86_64.rpm}.each do |pkg|
  dir = "/usr/local/src/"
  cookbook_file "#{dir}#{pkg}" do
    source pkg
  end

  rpm_package pkg do
    source "#{dir}#{pkg}"
    action :install
  end
end


#
# recpt1（録画ソフト）のインストール
#
%w{recpt1-7662d0ecd74b-1.x86_64.rpm}.each do |pkg|
  dir = "/usr/local/src/"
  cookbook_file "#{dir}#{pkg}" do
    source pkg
  end

  rpm_package pkg do
    source "#{dir}#{pkg}"
    action :install
  end
end

execute "ldconfig" do
  command "ldconfig"
  action :nothing
end

template "/etc/ld.so.conf.d/recpt1-lib.conf" do
  source "recpt1-lib.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, 'execute[ldconfig]', :immediately
end


#
# PT3ドライバのインストール
#
file "/etc/modprobe.d/blacklist.conf" do
  _file = Chef::Util::FileEdit.new(path)
  _file.insert_line_if_no_match(/^blacklist earth-pt1.*$/,"blacklist earth-pt1")
  _file.write_file
end

execute "reboot" do
  command "reboot"
  action :nothing
end

%w{pt3-8f47d0b5f1b6e2b0e54458772480c96f22ef4ab7-1.x86_64.rpm}.each do |pkg|
  dir = "/usr/local/src/"
  cookbook_file "#{dir}#{pkg}" do
    source pkg
  end

  rpm_package pkg do
    source "#{dir}#{pkg}"
    action :install
    notifies :run, 'execute[reboot]'
  end
end


#
# epgdumpr2（EPG取得ソフト）のインストール 
#
%w{epgdumpr2-20111001-1.x86_64.rpm}.each do |pkg|
  dir = "/usr/local/src/"
  cookbook_file "#{dir}#{pkg}" do
    source pkg
  end

  rpm_package pkg do
    source "#{dir}#{pkg}"
    action :install
  end
end

