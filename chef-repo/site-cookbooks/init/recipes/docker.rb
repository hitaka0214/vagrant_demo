=begin
### download repository
remote_file "#{Chef::Config[:file_cache_path]}/epel-release-7-1.norach.rpm" do
  source "http://download-i2.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-1.noarch.rpm"
  action :create
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/epel-release-7-1.norach.rpm") }
end

### install RPM
rpm_package "epel-release-7-1.noarch.rpm" do
  source "#{Chef::Config[:file_cache_path]}/epel-release-7-1.norach.rpm"
  action :install
  not_if "yum list installed | grep installed | grep -q epel-release"
end

### settings epel.repo
%w(/etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo).each do |f|
  file f do
    content lazy {
      _repo = Chef::Util::FileEdit.new(f)
      _repo.search_file_replace(/^enabled\s*=\s*1/, 'enabled=0')
      _repo.send(:editor).lines.join
    }
  end
end
=end

### install docker
%w(docker).each do |p|
  package p do
    action :install
  end
end

### service start docker
service "docker" do
  supports :start => true, :restart => true
  action [:enable, :restart]
end

### TEST ubuntu Dockerfile
%w(/home/vagrant/Dockerfile).each do |path|
  filename = File.basename(path) 
  cookbook_file path do
    source filename
    not_if {  ::File.exists?("#{path}") }
  end
end
