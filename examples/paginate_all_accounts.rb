require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

total_accounts = cluster.accounts.count
offset = 0
limit = 10

while offset < total_accounts
  cluster.accounts.per_page(limit).page(offset).all.each do |account|
    puts account.name
  end

  offset += limit
end