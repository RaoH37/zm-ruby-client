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
end
