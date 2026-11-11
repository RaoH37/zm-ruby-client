# frozen_string_literal: true

require_relative '../test_helper'

class AccountsTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_find_by_name_sends_get_account_request
    account_json = ZmTest::FakeData.account(name: 'user@domain.tld')
    @fake.on(:GetAccountRequest, { GetAccountResponse: { account: [account_json] } })

    @cluster.accounts.attrs('description').find_by(name: 'user@domain.tld')

    request = @fake.last_request(:GetAccountRequest)
    assert_equal 'name', request.body[:account][:by]
    assert_equal 'user@domain.tld', request.body[:account][:_content]
    assert_equal 'description', request.body[:attrs]
  end

  def test_find_by_builds_account_with_single_and_multi_valued_attributes
    json = ZmTest::FakeData.account(
      name: 'user@domain.tld',
      id: 'a1b2',
      description: 'my description',
      zimbraMailAlias: %w[alias1@domain.tld alias2@domain.tld]
    )
    json[:a] << { n: nil, _content: 'ignored' }
    @fake.on(:GetAccountRequest, { GetAccountResponse: { account: [json] } })

    account = @cluster.accounts.find_by(name: 'user@domain.tld')

    assert_instance_of Zm::Client::Account, account
    assert_equal 'a1b2', account.id
    assert_equal 'user@domain.tld', account.name
    assert_equal 'my description', account.description
    assert_equal %w[alias1@domain.tld alias2@domain.tld], account.zimbraMailAlias
  end

  def test_find_by_or_nil_returns_nil_when_account_does_not_exist
    @fake.fault(:GetAccountRequest, code: 'account.NO_SUCH_ACCOUNT')

    assert_nil @cluster.accounts.find_by_or_nil(name: 'unknown@domain.tld')
  end

  def test_find_by_raises_when_account_does_not_exist
    @fake.fault(:GetAccountRequest, code: 'account.NO_SUCH_ACCOUNT')

    error = assert_raises(Zm::Error::SoapError) { @cluster.accounts.find_by(name: 'unknown@domain.tld') }
    assert_equal 'account.NO_SUCH_ACCOUNT', error.code
  end

  def test_create_sends_name_and_attributes
    @fake.on(:CreateAccountRequest) do |request|
      { CreateAccountResponse: { account: [ZmTest::FakeData.account(name: request.body[:name], id: 'new-id')] } }
    end

    account = @cluster.accounts.new
    account.name = 'new@domain.tld'
    account.description = 'created by test'
    account.create!

    request = @fake.last_request(:CreateAccountRequest)
    assert_equal 'new@domain.tld', request.body[:name]
    assert_includes attr_nodes(request.body), { n: 'description', _content: 'created by test' }
    assert_equal 'new-id', account.id
  end

  def test_create_existing_account_raises
    @fake.fault(:CreateAccountRequest, code: 'account.ACCOUNT_EXISTS')

    account = @cluster.accounts.new
    account.name = 'existing@domain.tld'

    error = assert_raises(Zm::Error::SoapError) { account.create! }
    assert_equal 'account.ACCOUNT_EXISTS', error.code
  end

  def test_update_sends_multi_valued_attributes_as_separate_nodes
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = @cluster.accounts.new
    account.id = 'a1b2'

    account.update!({ description: 'new', zimbraMailAlias: %w[a@domain.tld b@domain.tld] })

    nodes = attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    assert_equal [
      { n: 'description', _content: 'new' },
      { n: 'zimbraMailAlias', _content: 'a@domain.tld' },
      { n: 'zimbraMailAlias', _content: 'b@domain.tld' }
    ], nodes
    assert_equal 'new', account.description
  end

  def test_update_accepts_keyword_attributes
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = @cluster.accounts.new { |acc| acc.id = 'a1b2' }

    assert account.update!(description: 'new', update_attributes: false)

    assert_equal [{ n: 'description', _content: 'new' }], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    assert_nil account.description
  end

  def test_update_does_not_mutate_given_hash
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = @cluster.accounts.new { |acc| acc.id = 'a1b2' }
    attributes = { description: 'new', unknownAttribute: 'x' }

    account.update!(attributes)

    assert_equal({ description: 'new', unknownAttribute: 'x' }, attributes)
  end

  def test_local_transport_updates_mail_transport
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = @cluster.accounts.new do |acc|
      acc.id = 'a1b2'
      acc.zimbraMailHost = 'mbox1.domain.tld'
    end

    account.local_transport!

    assert_equal [{ n: 'zimbraMailTransport', _content: 'lmtp:mbox1.domain.tld:7025' }],
                 attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
  end

  def test_update_all_accepts_keyword_attributes
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })

    @cluster.accounts.where('(mail=*@domain.tld)').update_all!(zimbraAccountStatus: 'locked')

    modify_requests = @fake.requests.select { |request| request.name == 'ModifyAccountRequest' }
    assert_equal 2, modify_requests.size
    assert(modify_requests.all? { |r| attr_nodes(r.body) == [{ n: 'zimbraAccountStatus', _content: 'locked' }] })
  end

  def test_update_all_continues_on_soap_error
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.fault(:ModifyAccountRequest, code: 'service.FAILURE')

    accounts = @cluster.accounts.update_all!({ description: 'x' })

    assert_equal(2, @fake.requests.count { |request| request.name == 'ModifyAccountRequest' })
    refute(accounts.any?(&:updated?))
  end

  def test_update_all_stops_on_soap_error
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.fault(:ModifyAccountRequest, code: 'service.FAILURE')

    @cluster.accounts.update_all!({ description: 'x' }, onerror: 'stop')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyAccountRequest' })
  end

  def test_delete_all_continues_on_soap_error
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.fault(:DeleteAccountRequest, code: 'service.FAILURE')

    @cluster.accounts.delete_all!

    assert_equal(2, @fake.requests.count { |request| request.name == 'DeleteAccountRequest' })
  end

  def test_aliases_add_accepts_frozen_email
    @fake.on(:AddAccountAliasRequest, { AddAccountAliasResponse: {} })
    account = @cluster.accounts.new do |a|
      a.id = 'account-id'
      a.name = 'user@domain.tld'
    end

    assert account.aliases.add!(' Alias@Domain.tld')

    assert_equal 'alias@domain.tld', @fake.last_request(:AddAccountAliasRequest).body[:alias]
    assert_includes account.aliases.all, 'alias@domain.tld'
    refute account.aliases.add!('ALIAS@domain.tld')
  end

  def test_created_at_and_last_logon_parse_ldap_timestamps
    @fake.on(:GetAccountRequest) do
      account = ZmTest::FakeData.account(name: 'user@domain.tld', zimbraCreateTimestamp: '20240102030405Z',
                                         zimbraLastLogonTimestamp: '20250607080910Z')
      { GetAccountResponse: { account: [account] } }
    end

    account = @cluster.accounts.find_by(name: 'user@domain.tld')

    assert_equal Time.utc(2024, 1, 2, 3, 4, 5), account.created_at
    assert_equal Time.utc(2025, 6, 7, 8, 9, 10), account.last_logon
  end

  def test_find_each_keeps_the_query_params_after_count
    @fake.on(:SearchDirectoryRequest) do |request|
      next { SearchDirectoryResponse: { num: 2 } } if request.body[:countOnly] == 1

      offset = request.body[:offset].to_i
      { SearchDirectoryResponse: { account: [ZmTest::FakeData.account(name: "user#{offset}@domain.tld")], num: 2 } }
    end

    names = []
    @cluster.accounts.ldap.order('name', 0).attrs('zimbraId').find_each(limit: 1) { |account| names << account.name }

    assert_equal %w[user0@domain.tld user1@domain.tld], names
    pages = @fake.requests.select { |r| r.name == 'SearchDirectoryRequest' && r.body[:countOnly].zero? }
    assert_equal 2, pages.size
    pages.each do |page|
      assert_equal [0, 'name', 0, 'zimbraId'], page.body.values_at(:applyCos, :sortBy, :sortAscending, :attrs)
    end
  end

  def test_find_in_batches_yields_each_page
    paginate_accounts(5)

    batches = []
    @cluster.accounts.find_in_batches(limit: 2) { |accounts| batches << accounts.map(&:name) }

    assert_equal [%w[user0@domain.tld user1@domain.tld], %w[user2@domain.tld user3@domain.tld],
                  %w[user4@domain.tld]], batches
    pages = @fake.requests.select { |r| r.name == 'SearchDirectoryRequest' && r.body[:countOnly].zero? }
    offsets = pages.map { |r| r.body.values_at(:offset, :limit) }
    assert_equal [[0, 2], [2, 2], [4, 2]], offsets
  end

  def test_find_in_batches_starts_at_the_offset
    paginate_accounts(5)

    batches = []
    @cluster.accounts.find_in_batches(offset: 3, limit: 2) { |accounts| batches << accounts.map(&:name) }

    assert_equal [%w[user3@domain.tld user4@domain.tld]], batches
  end

  def test_find_in_batches_keeps_the_query_params_for_every_page
    paginate_accounts(3)

    @cluster.accounts.ldap.where('(zimbraAccountStatus=locked)').attrs('zimbraId')
            .find_in_batches(limit: 2) { nil }

    pages = @fake.requests.select { |r| r.name == 'SearchDirectoryRequest' && r.body[:countOnly].zero? }
    assert_equal 2, pages.size
    pages.each do |page|
      assert_equal [0, '(zimbraAccountStatus=locked)', 'zimbraId'], page.body.values_at(:applyCos, :query, :attrs)
    end
  end

  def test_find_in_batches_stops_on_an_empty_page
    @fake.on(:SearchDirectoryRequest) do |request|
      next { SearchDirectoryResponse: { num: 4 } } if request.body[:countOnly] == 1

      { SearchDirectoryResponse: { num: 0 } }
    end

    batches = []
    @cluster.accounts.find_in_batches(limit: 2) { |accounts| batches << accounts }

    assert_empty batches
    pages = @fake.requests.count { |r| r.name == 'SearchDirectoryRequest' && r.body[:countOnly].zero? }
    assert_equal 1, pages
  end

  def test_find_in_batches_resets_the_collection_when_the_block_raises
    paginate_accounts(3)
    collection = @cluster.accounts.ldap.where('(zimbraAccountStatus=locked)')

    assert_raises(RuntimeError) { collection.find_in_batches(limit: 2) { raise 'boom' } }

    collection.all
    request = @fake.last_request(:SearchDirectoryRequest)
    assert_equal 1, request.body[:applyCos]
    assert_equal '', request.body[:query].to_s
    assert_nil request.body[:limit]
  end

  def test_all_returns_an_accounts_response
    search_accounts('a@domain.tld', 'b@domain.tld')

    accounts = @cluster.accounts.all

    assert_instance_of Zm::Client::AccountsResponse, accounts
    assert_equal %w[a@domain.tld b@domain.tld], accounts.map(&:name)
  end

  def test_empty_search_returns_an_empty_accounts_response
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { num: 0 } })

    accounts = @cluster.accounts.all

    assert_instance_of Zm::Client::AccountsResponse, accounts
    assert_empty accounts
  end

  def test_response_update_all_updates_its_accounts
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    accounts = @cluster.accounts.all

    assert_same accounts, accounts.update_all!(zimbraAccountStatus: 'locked')
    modify_requests = @fake.requests.select { |request| request.name == 'ModifyAccountRequest' }
    assert_equal 2, modify_requests.size
    assert(modify_requests.all? { |r| attr_nodes(r.body) == [{ n: 'zimbraAccountStatus', _content: 'locked' }] })
  end

  def test_response_update_all_stops_on_soap_error
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.fault(:ModifyAccountRequest, code: 'service.FAILURE')

    @cluster.accounts.all.update_all!({ description: 'x' }, onerror: 'stop')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyAccountRequest' })
  end

  def test_response_delete_all_deletes_its_accounts
    search_accounts('a@domain.tld', 'b@domain.tld')
    @fake.on(:DeleteAccountRequest, { DeleteAccountResponse: {} })

    @cluster.accounts.all.delete_all!

    assert_equal(2, @fake.requests.count { |request| request.name == 'DeleteAccountRequest' })
  end

  def test_find_in_batches_yields_responses_to_update
    paginate_accounts(3)
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })

    @cluster.accounts.find_in_batches(limit: 2) do |accounts|
      assert_instance_of Zm::Client::AccountsResponse, accounts
      accounts.update_all!(zimbraAccountStatus: 'locked')
    end

    assert_equal(3, @fake.requests.count { |request| request.name == 'ModifyAccountRequest' })
  end

  def test_find_each_returns_nil
    paginate_accounts(1)

    assert_nil(@cluster.accounts.find_each { nil })
  end

  private

  def paginate_accounts(total)
    @fake.on(:SearchDirectoryRequest) do |request|
      next { SearchDirectoryResponse: { num: total } } if request.body[:countOnly] == 1

      offset = request.body[:offset].to_i
      last = [offset + request.body[:limit].to_i, total].min
      accounts = (offset...last).map { |index| ZmTest::FakeData.account(name: "user#{index}@domain.tld") }
      { SearchDirectoryResponse: { account: accounts, num: total } }
    end
  end

  def search_accounts(*names)
    accounts = names.map { |name| ZmTest::FakeData.account(name:) }
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { account: accounts, num: accounts.size } })
  end
end
