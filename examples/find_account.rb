require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

account = cluster.accounts.find_by name: 'maxime@domain.tld'

puts account.name
puts account.id
puts account.zimbraAccountStatus
puts account.zimbraMailHost