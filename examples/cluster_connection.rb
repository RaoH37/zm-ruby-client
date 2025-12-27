require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_url = 'https://mail.zimbra.lan:7071'
  cc.zimbra_admin_login = 'admin@domain.tld'
  cc.zimbra_admin_password = 'secret'
  cc.zimbra_public_url = 'https://mail.zimbra.lan'
end

cluster = Zm::Client::Cluster.new(config)
cluster.login

puts cluster.token