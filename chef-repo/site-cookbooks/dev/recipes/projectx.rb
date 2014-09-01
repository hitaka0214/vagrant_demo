# git clone
%w(/home/vagrant/projectx).each do |d|
  directory d do
    owner 'vagrant'
    group 'vagrant'
    recursive true
    action :create
  end

  git d do
    user 'vagrant'
    group 'vagrant'
    repository "https://github.com/hitaka0214/vagrant_demo.git"
    reference "master"
    action :sync
  end 
end

# move nginx conf
%w(/etc/nginx/conf.d/default.conf).each do |path|
  filename = File.basename(path)
  cookbook_file path do
    source filename
  end
end

# change permission
%w(/home/vagrant).each do |path|
  execute "#{path} permission" do
    not_if "test `stat -c '%a" #{path}` -eq '755'"
    command "chmod 0755 #{path}"
    user "vagrant"
    group "vagrant"
    action :run
  end
end
