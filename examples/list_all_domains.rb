require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

cluster.domains.all.each do |domain|
  puts domain.name
end