require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_host = 'mail.zimbra.lan'
  cc.zimbra_admin_scheme = 'https'
  cc.zimbra_admin_port = 7071
  cc.zimbra_admin_login = 'admin@domain.tld'
  cc.zimbra_admin_password = 'secret'
  cc.zimbra_public_host = 'mail.zimbra.lan'
  cc.zimbra_public_scheme = 'https'
  cc.zimbra_public_port = 443
end

cluster = Zm::Client::Cluster.new(config)
cluster.login

puts cluster.token