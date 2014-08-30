require 'serverspec'
require 'pathname'
require 'net/ssh'
 
include SpecInfra::Helper::Ssh
include SpecInfra::Helper::DetectOS

#### Nginx
%w(nginx).each do |package| 
  describe package(package) do
    it { should be_installed }
  end
  describe service(package) do
    it { should be_enabled }
    it { should be_running }
  end
end
 
describe port(80) do
    it { should be_listening }
end
