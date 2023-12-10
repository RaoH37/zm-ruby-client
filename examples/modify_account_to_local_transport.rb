require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

account = cluster.accounts.attrs('zimbraMailHost').find_by name: 'maxime@domain.tld'

account.local_transport!
