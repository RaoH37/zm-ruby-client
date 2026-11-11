# frozen_string_literal: true

require_relative '../test_helper'

class AccountsResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_by_server_groups_the_accounts_by_mail_host
    search_accounts(
      ['a@domain.tld', { zimbraMailHost: 'mbox1.domain.tld' }],
      ['b@domain.tld', { zimbraMailHost: 'mbox2.domain.tld' }],
      ['c@domain.tld', { zimbraMailHost: 'mbox1.domain.tld' }]
    )

    servers = @cluster.accounts.all.by_server

    assert_equal({ 'mbox1.domain.tld' => %w[a@domain.tld c@domain.tld], 'mbox2.domain.tld' => %w[b@domain.tld] },
                 servers.transform_values { |accounts| accounts.map(&:name) })
    assert(servers.values.all?(Zm::Client::AccountsResponse))
  end

  def test_by_server_groups_can_be_updated
    search_accounts(['a@domain.tld', { zimbraMailHost: 'mbox1.domain.tld' }],
                    ['b@domain.tld', { zimbraMailHost: 'mbox2.domain.tld' }])
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })

    @cluster.accounts.all.by_server['mbox1.domain.tld'].update_all!(description: 'x')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyAccountRequest' })
  end

  def test_statuses_counts_the_accounts_by_status
    search_accounts(
      ['a@domain.tld', { zimbraAccountStatus: 'active' }],
      ['b@domain.tld', { zimbraAccountStatus: 'locked' }],
      ['c@domain.tld', { zimbraAccountStatus: 'active' }]
    )

    assert_equal({ 'active' => 2, 'locked' => 1 }, @cluster.accounts.all.statuses)
  end

  def test_accounts_without_the_attribute_are_counted_under_nil
    search_accounts(['a@domain.tld', {}], ['b@domain.tld', { zimbraAccountStatus: 'active' }])

    accounts = @cluster.accounts.attrs('description').all

    assert_equal({ nil => 1, 'active' => 1 }, accounts.statuses)
    assert_equal [nil], accounts.by_server.keys
  end

  def test_empty_response
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { num: 0 } })

    accounts = @cluster.accounts.all

    assert_empty accounts.by_server
    assert_empty accounts.statuses
  end

  def test_domain_accounts_return_an_accounts_response
    search_accounts(['a@domain.tld', {}])
    domain = Zm::Client::Domain.new(@cluster) { |d| d.name = 'domain.tld' }

    assert_instance_of Zm::Client::AccountsResponse, domain.accounts.all
  end

  def test_other_admin_collections_return_an_admin_objects_response
    coses_json = [{ name: 'default', id: 'c1', a: [] }]
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { cos: coses_json, num: 1 } })

    coses = @cluster.coses.all

    assert_instance_of Zm::Client::Base::AdminObjectsResponse, coses
    assert_equal %w[default], coses.map(&:name)
  end

  private

  def search_accounts(*accounts)
    json = accounts.map { |name, attributes| ZmTest::FakeData.account(name:, **attributes) }
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { account: json, num: json.size } })
  end
end
