#
# Cookbook Name:: init
# Recip%e:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# https://www.zabbix.com/documentation/2.2/manual/installation/requirements


### vim
vimname = ''
if 6 <= node[:platform_version].to_i
  vimname = 'vim'
elsif 5 <= node[:platform_version].to_i
  vimname = 'vim-enhanced'
end

package vimname do
  action :install
  not_if { vimname.empty? }
end

#### vim color scheme
git "#{Chef::Config[:file_cache_path]}/molokai" do
  user 'root'
  group 'root'
  repository "https://github.com/tomasr/molokai.git"
  reference "master"
  action :sync
end

%w(/home/vagrant/.vimrc).each do |f|
  filename = File.basename(f)
  template f do
    path f
    source "#{filename}.erb"
    owner "vagrant"
    group "vagrant"
    mode  "0644"
    action :create_if_missing
  end
end
directory "/home/vagrant/.vim/colors" do
  owner "vagrant"
  group "vagrant"
  recursive true
  mode 0755
  action :create
  not_if { File.exists? "/home/vagrant/.vim/colors" }
end
file "/home/vagrant/.vim/colors/molokai.vim" do
  content lazy {
    IO.read("#{Chef::Config[:file_cache_path]}/molokai/colors/molokai.vim")
  }
  not_if { File.exists? "/home/vagrant/.vim/colors/molokai.vim" }
end


### GNU screen
package 'screen' do
  action :install
end

%w(/home/vagrant/.screenrc).each do |f|
  filename = File.basename(f)
  template f do
    path f
    source "#{filename}.erb"
    owner "vagrant"
    group "vagrant"
    mode  "0644"
    action :create_if_missing
  end
end


#### emacs
%w(emacs emacs-el).each do |p|
  package p do
    action :install
  end
end
%w(/home/vagrant/.emacs.el).each do |f|
  filename = File.basename(f)
  template f do
    path f
    source "#{filename}.erb"
    owner "vagrant"
    group "vagrant"
    mode  "0644"
    action :create_if_missing
  end
end

