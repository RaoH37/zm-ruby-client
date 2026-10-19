# zm-ruby-client

[![Gem Version](https://img.shields.io/gem/v/zm-ruby-client)](https://rubygems.org/gems/zm-ruby-client)
![Ruby](https://img.shields.io/badge/ruby-3.3%2B-CC342D)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE)

**Zimbra and Carbonio in plain Ruby: code that reads like what it does.**

```ruby
cluster.accounts.find_by(name: 'john@domain.tld').update!(zimbraAccountStatus: 'locked')
```

No XML, no SOAP envelopes, no token juggling. Read the line out loud, that's what it does.

- **Readable**: short verbs (`find_by`, `where`, `save!`, `update!`, `delete!`) and chainable queries.
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

TLS certificates are not verified by default. To enable verification:

```ruby
cc.ssl_verify  = true
cc.ssl_ca_file = '/etc/ssl/certs/zimbra-ca.pem' # optional, for a private CA (or ssl_ca_path)
```

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

**Create anything with a block.**

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

## Type signatures

RBS signatures for the public API are shipped in `sig/`. [rbs collection](https://github.com/ruby/rbs) picks them up
from the installed gem, for use with [Steep](https://github.com/soutaro/steep) or your editor:

```bash
bundle exec rbs collection install
```

## Upgrading from 3.0

3.1 requires Ruby 3.3, moves the error classes to `Zm::Error` (`rescue Zm::Error::SoapError`) and raises
`Zm::Error::ConnectionError` on network failures. The 3.0 names (`Zm::Client::SoapError`…) still work but print a
deprecation warning: they will be removed in 4.0. See the [upgrade notes](CHANGELOG.md#upgrading-from-30) for the
full list.

## Development

```bash
bundle install
bundle exec rake test          # offline unit tests, no server needed
bundle exec rake rbs:validate  # check the RBS signatures
bundle exec rake rbs:test      # unit tests with RBS runtime type checking
bundle exec rubocop
```

**Live tests** run real CRUD operations (accounts, domains, COS, distribution lists, resources, and the folders,
messages, contacts, appointments, tags, signatures and identities of an account) against a Zimbra or Carbonio server:

```bash
ZIMBRA_ADMIN_URL=https://mail.domain.tld:7071 \
ZIMBRA_ADMIN_LOGIN=admin@domain.tld \
ZIMBRA_ADMIN_PASSWORD=secret \
bundle exec rake test:live
```

Each test creates its own data (accounts, lists and resources in a temporary `zmlive-*.test` domain) and deletes it
afterwards, even when the test fails. They are skipped when a variable is missing. Set `ZIMBRA_LOG_PATH=/dev/stdout`
to see the SOAP requests. Use a test server: the tests need full admin rights and create and delete domains.

## Learn more

- [examples/](examples): ready-to-run scripts
- [CHANGELOG.md](CHANGELOG.md): what's new

## License

GPL-3.0, by Maxime Désécot.
