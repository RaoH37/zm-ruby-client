require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

account = cluster.accounts.find_by name: 'maxime@domain.tld'
account.login

html = account.signatures.new
html.name = 'Example HTML'
html.html = '<b>Have a good day !</b>'
html.save!

account.signatures.all.each do |sig|
  puts sig.to_s
end
