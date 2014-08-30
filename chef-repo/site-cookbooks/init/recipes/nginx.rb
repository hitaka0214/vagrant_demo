### download repository
remote_file "#{Chef::Config[:file_cache_path]}/nginx-release-centos-7.0.el7.ngx.noarch.rpm" do
  source "http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm"
  action :create
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/nginx-release-centos-7.0.el7.ngx.noarch.rpm") }
end

### install RPM 
rpm_package "nginx-release-centos-7.0.el7.ngx.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/nginx-release-centos-7.0.el7.ngx.noarch.rpm"
  action :install
  not_if "yum list installed | grep installed | grep -q nginx-release"
end

### settings nginx.repo
%w(/etc/yum.repos.d/nginx.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end

### install nginx
%w(nginx).each do |p|
  package p do
    options "--enablerepo=nginx"
    action :install
  end
end

### service start nginx
service "nginx" do
  supports :start => true, :restart => true
  action [:enable, :restart]
end

### add http access rules for firewalld (don't works...why?)
=begin
execute "firewall-cmd http" do
  command <<-EOF
    firewall-cmd --add-service=http --zone=public --permanent
  EOF
  not_if "firewall-cmd --list-service --zone=public | grep http"
end
=end

### service stop firewalld
service "firewalld" do
  action [:disable, :stop]
end
