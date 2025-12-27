require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

cluster.accounts.where('(!(zimbraAccountStatus=active))').attrs('zimbraAccountStatus').all.each do |account|
  puts [account.name, account.zimbraAccountStatus].join(' => ')
end
