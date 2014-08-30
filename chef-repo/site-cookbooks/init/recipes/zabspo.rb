#
# Cookbook Name:: init
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# https://www.zabbix.com/documentation/2.2/manual/installation/requirements
%w(postgresql-server net-snmp-utils).each do |p|
  package p do
    action :install
  end
end

%w(libmcrypt).each do |p|
  package p do
    options "--enablerepo=epel"
    action :install
  end
end

%w(php55u-pgsql php55u-mcrypt php55u-pecl-jsonc).each do |p|
  package p do
    options "--enablerepo=ius"
    action :install
  end
end

%w(/var/lib/pgsql/data/postgresql.conf).each do |d|
  execute "initdb" do
    command <<-EOF
      service postgresql initdb
    EOF
    not_if {File.exists?(d)}
  end
end

%w(postgresql).each do |s|
  service s do
    supports :status => true, :restart => true
    action [:enable, :start]
  end
end

%w(/etc/hosts).each do |f|
  hosts = Chef::Util::FileEdit.new("/etc/hosts")
  hosts.insert_line_if_no_match("dccsweb01", "10.16.230.142 dccsweb01")
  hosts.write_file
end

%w(/home/zabbix/zabspo).each do |d|
  directory d do
    owner 'zabbix'
    group 'zabbix'
    recursive true
    action :create
  end

  ENV["http_proxy"]=""
  git d do
    user 'zabbix'
    group 'zabbix'
    repository "http://dccsweb01/git/zabspo.git"
    reference "master"
    action :sync
  end
end

link "/home/zabbix/zabspo5" do
  to "/home/zabbix/zabspo/zabspo"
  link_type :symbolic
end


remote_file "#{Chef::Config[:file_cache_path]}/Smarty-2.6.28.tar.gz" do
  source "http://www.smarty.net/files/Smarty-2.6.28.tar.gz"
  action :create
end

execute "install smarty" do
  cwd "#{Chef::Config[:file_cache_path]}"
  command <<-EOF
    tar -xvzf Smarty-2.6.28.tar.gz
    mv Smarty-2.6.28/libs /usr/lib64/php/Smarty
  EOF
  not_if {File.exists?("/usr/lib64/php/Smarty")}
end

%w(/home/zabbix/zabspo5/log /home/zabbix/zabspo5/template_c).each do |d|
  directory d do
    owner 'zabbix'
    group 'zabbix'
    mode 0777
    recursive true
    action :create
  end
end
%w(/var/lib/pgsql/data/pg_hba.conf).each do |path|
  filename = File.basename(path)
  target = "#{filename}.erb"
  template path do
    path path
    source target
    owner "postgres"
    group "postgres"
    mode 0600
    notifies :restart, resources(:service => "postgresql")
  end
end

execute "create zabspo database" do
  user 'postgres'
  group 'postgres'
  cwd "/home/zabbix/zabspo/zabspo/sql"
  command <<-EOF
    createdb -U postgres zab_actions
    psql -U postgres -d zab_actions -f Tm_Hostcode.sql
    psql -U postgres -d zab_actions -f Tm_Projectscode.sql
    psql -U postgres -d zab_actions -f Td_Event_Status.sql
    psql -U postgres -d zab_actions -f Td_Zab_Action.sql
    psql -U postgres -d zab_actions -f Vd_Zab_Action.sql
    createuser -s -d -r dbuser -U postgres
  EOF
  not_if "psql -l -U postgres | grep zab_actions" 
end

%w(/etc/httpd/conf.d/zabspo.conf /etc/httpd/conf.d/zabspol.conf).each do |path|
  filename = File.basename(path)
  target = "#{filename}.erb"
  template path do
    path path
    source target
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "httpd")
  end
end

execute "install composer" do
  cwd "/tmp"
  command <<-EOF
    curl -sS https://getcomposer.org/installer | php
    cp -p composer.phar /usr/local/bin/composer
  EOF
  not_if {File.exists?("/usr/local/bin/composer")}
end

execute "using composer" do
  user "zabbix"
  group "zabbix"
  cwd "/home/zabbix/zabspo/zabspol"
  command <<-EOF
    composer install
    chmod -R 777 app/storage
  EOF
  not_if {File.exists?("/home/zabbix/zabspo/zabspol/vendor")}
end


p Chef::Config.inspect
cookbook_file "#{Chef::Config[:file_cache_path]}/create_zabbix_item.rb" do
  source "create_zabbix_item.rb"
end
execute "create zabbix item" do
  command <<-EOF
    ruby "#{Chef::Config[:file_cache_path]}/create_zabbix_item.rb"
  EOF
end

execute "create zabspol database" do
  command <<-EOF
    echo "create database zabspol character set utf8 collate utf8_bin;" | mysql -uroot
    echo "grant all privileges on zabspol.* to zabspol@localhost identified by 'zabspol';" | mysql -uroot
  EOF
  not_if "mysqlshow | grep zabspol"
end

