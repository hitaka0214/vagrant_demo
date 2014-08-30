cookbook_path    ["cookbooks", "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags"
#encrypted_data_bag_secret "data_bag_key"

knife[:berkshelf_path] = "cookbooks"

if ENV["http_proxy"]
  require 'rest-client'
  RestClient.proxy = ENV["http_proxy"]

  require 'uri'
  proxy_env = URI.parse(ENV["http_proxy"])
  proxy_user, proxy_pass = proxy_env.userinfo.split(":")

  http_proxy "http://#{proxy_env.host}:#{proxy_env.port}"
  https_proxy "http://#{proxy_env.host}:#{proxy_env.port}"
  http_proxy_user proxy_user
  http_proxy_pass proxy_pass
  https_proxy_user proxy_user
  https_proxy_pass proxy_pass
  no_proxy "192.168.*"
end
