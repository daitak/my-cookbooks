#
# Cookbook Name:: dev_env
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{vim-enhanced zsh screen ctags}.each do |pkg|
  package pkg do
    action :install
  end
end

DIRNAME="home_settings"
GITHUB_USER="daitak"
REPO_NAME="#{DIRNAME}.git"
git "/home/#{node['dev_env']['user']}/#{DIRNAME}" do
  repository "https://github.com/#{GITHUB_USER}/#{REPO_NAME}"
  revision "master"
  user node['dev_env']['user']
  action :sync
end

%w{.vim .screenrc .vimrc .zshrc cdd}.each do |obj|
  link "/home/#{node['dev_env']['user']}/#{obj}" do
    to "/home/#{node['dev_env']['user']}/#{DIRNAME}/#{obj}"
  end
end

bash "Set user's shell to zsh" do
    code <<-EOT
        chsh -s /bin/zsh #{node['dev_env']['user']}
          EOT
            not_if 'test "/bin/zsh" = "$(grep #{node["dev_env"]["user"]} /etc/passwd | cut -d: -f7)"'
end

bash "Modify remote repo for pushing to github" do
  url = "https://#{GITHUB_USER}@github.com/#{GITHUB_USER}/#{REPO_NAME}"
  user node['dev_env']['user'] 
  code <<-EOT
        cd /home/#{node['dev_env']['user']}/#{DIRNAME}
        git remote set-url origin #{url}
        EOT
        not_if "test #{url} = \"cat /home/#{node['dev_env']['user']}/#{DIRNAME} | grep url | awk \'{ print $3}\'   \""
end
