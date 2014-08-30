#
# Cookbook Name:: init
# Recip%e:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# https://www.zabbix.com/documentation/2.2/manual/installation/requirements

### case remi
###remote_file "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm" do
###  source "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
###  action :create
###end
###
###rpm_package "remi-release-6.rpm" do
###  source "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm"
###  action :install
###end
###%w(php php-mysql php-gd php-mbstring php-bcmath php-xml).each do |p|
###  package p do
###    options "--enablerepo=remi"
###    action :install
###  end
###end


### case epel ( needed by ius repository )
remote_file "#{Chef::Config[:file_cache_path]}/epel-release-6.8.noarch.rpm" do
  source "https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
  action :create
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/epel-release-6.8.noarch.rpm") }
end

rpm_package "epel-release-6.8.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/epel-release-6.8.noarch.rpm"
  action :install
  not_if "yum list installed | grep installed | grep -q epel"
end

%w(/etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end

### case IUS
remote_file "#{Chef::Config[:file_cache_path]}/ius-release-1.0-11.ius.centos6.noarch.rpm" do
  source "http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-11.ius.centos6.noarch.rpm"
  action :create
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/ius-release-1.0-11.ius.centos6.noarch.rpm") }
end

rpm_package "ius-release-1.0-11.ius.centos6.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/ius-release-1.0-11.ius.centos6.noarch.rpm"
  action :install
  not_if "yum list installed | grep installed | grep -q ius"
end

%w(
  /etc/yum.repos.d/ius.repo 
  /etc/yum.repos.d/ius-archive.repo
  /etc/yum.repos.d/ius-dev.repo
  /etc/yum.repos.d/ius-testing.repo
).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end


### php
%w(php55u php55u-mysql php55u-gd php55u-mbstring php55u-bcmath php55u-xml).each do |p|
  package p do
    options "--enablerepo=ius"
    action :install
  end
end


### mysql
remote_file "#{Chef::Config[:file_cache_path]}/mysql-community-release-el6-5.noarch.rpm" do
  source "http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm"
  action :create
end

rpm_package "mysql-community-release-el6-5.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/mysql-community-release-el6-5.noarch.rpm"
  action :install
end

%w(/etc/yum.repos.d/mysql-community.repo /etc/yum.repos.d/mysql-community-source.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end

%w(mysql-community-server).each do |p|
  package p do
    action :install
    options "--enablerepo=mysql56-community"
  end
end


%w(/etc/my.cnf).each do |f| ### minimum memory size for virtual machine
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^# innodb_buffer_pool_size = 128M/, "innodb_buffer_pool_size = 8M\n")
      _repo.send(:editor).lines.join
    }
  end
end
bash "ulimit -s unlimited" do ### for virtual machine
  user "root"
  group "root"
  code <<-EOH
    ulimit -s unlimited
  EOH
end

%w(mysqld).each do |s|
  service s do
    supports :status => true, :restart => true
    action [:enable, :restart]
  end
end

# https://www.zabbix.com/documentation/2.2/manual/installation/install_from_packages
# http://stackoverflow.com/questions/18174557/chef-correct-way-to-load-new-rpm-and-install-package

p ENV
remote_file "#{Chef::Config[:file_cache_path]}/zabbix-release-2.2-1.el6.noarch.rpm" do
  source "http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm"
  action :create
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/zabbix-release-2.2-1.el6.noarch.rpm") }
end

rpm_package "zabbix-release-2.2-1.el6.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/zabbix-release-2.2-1.el6.noarch.rpm"
  action :install
  not_if "yum list installed | grep installed | grep -q zabbix-release"
end

%w(/etc/yum.repos.d/zabbix.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
    not_if "grep -q 'enabled\s*=\s*0' f"
  end
end

%w(/etc/yum.repos.d/zabbix.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end

%w(iksemel fping).each do |p| # needed by zabbix-server
  package p do
    action :install
    options "--enablerepo=epel"
  end
end

%w(zabbix-server zabbix-server-mysql zabbix-web-mysql zabbix-agent).each do |p|
  package p do
    action :install
    options "--enablerepo=zabbix"
  end
end

%w(httpd).each do |s|
  service s do
    supports :status => true, :restart => true
    action [:enable, :start]
  end
end

execute "create zabbix database" do
  command <<-EOF
    echo "create database zabbix character set utf8 collate utf8_bin;" | mysql -uroot
    echo "grant all privileges on zabbix.* to zabbix@'localhost' identified by 'zabbix';" | mysql -uroot
    cd /usr/share/doc/zabbix-server-mysql-2.2.*/create
    mysql -uzabbix -pzabbix zabbix < schema.sql
    mysql -uzabbix -pzabbix zabbix < images.sql
    mysql -uzabbix -pzabbix zabbix < data.sql
  EOF
  not_if "mysqlshow -uroot | grep -q zabbix"
end

%w(/etc/zabbix/zabbix_server.conf).each do |path|
  filename = File.basename(path)
  file path do
    content lazy {
      _repo = Chef::Util::FileEdit.new(path)
      _repo.search_file_replace(/AlertScriptsPath=\/usr\/lib\/zabbix\/alertscripts/,'AlertScriptsPath=/home/zabbix/zabspo5/bin')
      _repo.send(:editor).lines.join
    }
  end
  file path do
    content lazy {
      _repo = Chef::Util::FileEdit.new(path)
      _repo.insert_line_after_match(/^# DBPassword=/, "DBPassword=zabbix\n")
      _repo.send(:editor).lines.join
    } 
    not_if "cat /etc/zabbix/zabbix_server.conf | grep -q '^DBPassword'"
  end
end

%w(/etc/php.ini).each do |path|
  filename = File.basename(path)
  target = "#{Chef::Config[:file_cache_path]}/#{filename}.erb"
  execute target do
    command <<-EOF
      cat #{path} > #{target}
      echo "date.timezone = Asia/Tokyo" >> #{target}
    EOF
    not_if { ::File.exists?("#{target}")}
  end
  template path do
    path path
    source target
    local true
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "httpd")
  end
end

%w(/etc/zabbix/web/zabbix.conf.php).each do |path|
  filename = File.basename(path)
  template path do
    path path
    source "#{filename}.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "httpd")
  end
end

%w(zabbix-server zabbix-agent).each do |s|
  service s do
    supports :status => true, :restart => true
    action [:enable, :restart]
  end
end
