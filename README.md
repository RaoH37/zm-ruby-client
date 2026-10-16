# zm-ruby-client

[![Gem Version](https://img.shields.io/gem/v/zm-ruby-client)](https://rubygems.org/gems/zm-ruby-client)
![Ruby](https://img.shields.io/badge/ruby-3.3%2B-CC342D)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE)

**Drive Zimbra and Carbonio from Ruby the way ActiveRecord drives your database.**

No XML, no SOAP envelopes, no token juggling: just collections and objects with the methods you already know,
`find_by`, `where`, `save!`, `update!`, `delete!`.

- **Familiar**: ActiveRecord-style API with chainable queries.
- **Complete**: admin side (accounts, domains, COS, distribution lists, servers…) and mailbox side
  (messages, folders, contacts, calendars, tags, shares…), over both SOAP and REST.
- **Lightweight**: Ruby 3.3+, few dependencies, code autoloaded on demand.

## Install

```bash
gem install zm-ruby-client
```

## Connect

```ruby
require 'zm-ruby-client'

config = Zm::Client::ClusterConfig.new do |cc|
  cc.zimbra_admin_url      = 'https://mail.domain.tld:7071'
  cc.zimbra_admin_login    = 'admin@domain.tld'
  cc.zimbra_admin_password = 'secret'
end

cluster = Zm::Client::Cluster.new(config)
cluster.login
```

Prefer a file? `Zm::Client::ClusterConfig.new('config.json')` (or `.yml`), see [examples/config.json](examples/config.json).

## Feel the difference

**Find an account, change it.**

```ruby
account = cluster.accounts.find_by name: 'john@domain.tld'
account.zimbraAccountStatus # => "active"

account.update!(zimbraAccountStatus: 'locked')
```

**Query LDAP like a database.** Pagination is handled for you.

```ruby
cluster.accounts
       .where('(zimbraLastLogonTimestamp<=20250101000000Z)')
       .attrs('zimbraLastLogonTimestamp')
       .find_each { |account| puts "#{account.name} last seen #{account.last_logon}" }
```

**Lock every dormant account. One line.**

```ruby
cluster.accounts.where('(zimbraLastLogonTimestamp<=20250101000000Z)').update_all!(zimbraAccountStatus: 'locked')
```

**Step into any mailbox, no user password needed.**

```ruby
account.login

account.messages.where('is:unread from:boss@domain.tld').all.each do |message|
  puts "#{message.date}  #{message.su}"
end
```

**Create things the way you create records.**

```ruby
folder = account.folders.new do |f|
  f.name  = 'Invoices'
  f.color = 3
end
folder.save!
```

**Import and export whole folders.**

```ruby
account.folders.find(10).upload('holidays.ics')  # Calendar
account.folders.find(2).download('inbox.tgz')    # Inbox backup
account.folders.find(7).export_contacts          # Contacts, as CSV
```

**Ask quick questions.**

```ruby
cluster.email_exist?('john@domain.tld')               # => true
cluster.accounts.where('(mail=*@domain.tld)').count   # => 1250
```

## Learn more

- [examples/](examples): ready-to-run scripts
- [CHANGELOG.md](CHANGELOG.md): what's new

## License

GPL-3.0, by Maxime Désécot.
