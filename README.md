# zm-ruby-client

Library to interface with Zimbra simply.

## Examples of uses:

```ruby
admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('config.json'))
admin.login

filter = '(&(mail=*@domain.tld)(zimbraLastLogonTimestamp<=20190225000000Z))'
admin.accounts.where(filter).each do |account|
  begin
    account.account_login
    puts account.infos
  rescue Zm::Client::SoapError => e
    puts e.message
  end
end
```
