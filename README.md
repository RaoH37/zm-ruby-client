# zm-ruby-client

Library to interface with Zimbra simply.

Author: Maxime Désécot <maxime.desecot@gmail.com>

## Installation

OS: Linux distribution LTS

Language: Ruby2.7+

```bash
gem install zm-ruby-client
```

## Examples of uses:

### Connection:

```ruby
config = Zm::Client::ClusterConfig.new('config.json')
admin = Zm::Client::Cluster.new(config)
admin.login
````
or
```ruby
config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_host = 'mail.domain.tld'
  cc.zimbra_admin_scheme = 'https'
  cc.zimbra_admin_port = 7071
  cc.zimbra_admin_login = 'admin@domain.tld'
  cc.zimbra_admin_password = 'secret'
end
admin = Zm::Client::Cluster.new(config)
admin.login
````

### List all accounts

```ruby
filter = '(&(mail=*@domain.tld)(zimbraLastLogonTimestamp<=20190225000000Z))'
accounts = admin.accounts.where(filter).all
```

### Find an account

```ruby
account = admin.accounts.find_by name: 'maxime@domain.tld'
```

### Create an account

```ruby
account = Zm::Client::Account.new(admin) do |acc|
  acc.name = 'maxime@domain.tld'
  acc.givenName = 'Maxime'
  acc.sn = 'DÉSÉCOT'
end

account.save
```