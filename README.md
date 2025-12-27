# zm-ruby-client

Library to interface with Zimbra simply.

Author: Maxime Désécot <maxime.desecot@gmail.com>

## Installation

OS: Linux distribution LTS

Language: Ruby3.2+

```bash
gem install zm-ruby-client
```

## Examples of uses:

### Connection:

```ruby
cluster = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('config.json'))
cluster.login
````
or
```ruby
config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_url = 'https://mail.domain.tld:7071'
  cc.zimbra_admin_login = 'admin@domain.tld'
  cc.zimbra_admin_password = 'secret'
end
cluster = Zm::Client::Cluster.new(config)
cluster.login
````

### List all accounts

```ruby
filter = '(&(mail=*@domain.tld)(zimbraLastLogonTimestamp<=20190225000000Z))'
accounts = cluster.accounts.where(filter).all
```

### Find an account

```ruby
account = cluster.accounts.find_by name: 'maxime@domain.tld'
```

### Create an account

```ruby
account = Zm::Client::Account.new(cluster) do |acc|
  acc.name = 'maxime@domain.tld'
end
account.zimbraMailQuota = 0
account.save
```