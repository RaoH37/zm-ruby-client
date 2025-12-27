require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

cluster.accounts.find_each do |account|
  puts account.name
end
