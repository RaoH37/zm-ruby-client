require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

puts cluster.token