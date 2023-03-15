# zm-ruby-client

Library to interface with Zimbra simply.

## Installation

```bash
sudo apt install make gcc curl libcurl4-openssl-dev
```

## Examples of uses:

### Connection:

```ruby
admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('config.json'))
admin.login
````
or
```ruby
config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_host = 'mail.domain.tld'
  cc.zimbra_admin_scheme = 'https'
  cc.zimbra_admin_port = 443
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
end
account.zimbraMailQuota = 0
account.save
```