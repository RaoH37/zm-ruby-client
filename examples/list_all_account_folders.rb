require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

account = cluster.accounts.find_by name: 'maxime@domain.tld'
account.login

account.folders.all.each do |folder|
  puts [folder.absFolderPath, folder.size].join(' => ')
end