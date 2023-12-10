require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new('./config.json')

cluster = Zm::Client::Cluster.new(config)
cluster.login

account = cluster.accounts.find_by name: 'maxime@domain.tld'

identity_name = 'desecot@domain.tld'

account.aliases.add!(identity_name)

account.login

avatar = account.identities.new do |ident|
  ident.name = identity_name
end

sig = account.signatures.all.find { |s| s.name == 'Example HTML' }

avatar.zimbraPrefDefaultSignatureId = sig.id
avatar.save!
