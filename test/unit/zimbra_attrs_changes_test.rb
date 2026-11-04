# frozen_string_literal: true

require_relative '../test_helper'

class ZimbraAttrsChangesTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_loaded_account_has_no_changes
    account = find_account(description: 'loaded', zimbraMailForwardingAddress: %w[a@d.tld b@d.tld])

    refute account.zimbra_attrs_changed?
    assert_empty account.zimbra_attrs_changed
    refute account.instance_variable_defined?(:@zimbra_attrs_changes)
  end

  def test_setter_tracks_writable_attributes_only
    account = find_account

    account.description = 'new'
    account.zimbraId = 'readonly'

    assert account.zimbra_attr_changed?(:description)
    assert account.zimbra_attr_changed?('description')
    refute account.zimbra_attr_changed?(:zimbraId)
    assert_equal [:description], account.zimbra_attrs_changed
  end

  def test_modify_sends_changed_attributes_only
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'old', displayName: 'John', zimbraMailForwardingAddress: %w[a@d.tld])

    account.description = 'new'
    account.zimbraMailForwardingAddress = %w[a@d.tld b@d.tld]

    assert account.modify!

    assert_equal [
      { n: 'description', _content: 'new' },
      { n: 'zimbraMailForwardingAddress', _content: 'a@d.tld' },
      { n: 'zimbraMailForwardingAddress', _content: 'b@d.tld' }
    ], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    refute account.zimbra_attrs_changed?
  end

  def test_modify_without_changes_sends_no_request
    account = find_account(description: 'old')

    refute account.modify!
    assert_nil @fake.last_request(:ModifyAccountRequest)
  end

  def test_modify_with_force_sends_all_set_writable_attributes
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'old', zimbraMailForwardingAddress: %w[a@d.tld b@d.tld])
    account.displayName = 'John'

    assert account.modify!(force: true)

    nodes = attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    assert_includes nodes, { n: 'description', _content: 'old' }
    assert_includes nodes, { n: 'displayName', _content: 'John' }
    assert_includes nodes, { n: 'zimbraMailForwardingAddress', _content: 'b@d.tld' }
    refute(nodes.any? { |node| node[:n] == 'zimbraId' })
    refute account.zimbra_attrs_changed?
  end

  def test_update_sends_only_values_different_from_the_object
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'same', displayName: 'John', zimbraMailForwardingAddress: %w[a@d.tld])

    assert account.update!(description: 'same', displayName: 'Jane', zimbraMailForwardingAddress: %w[a@d.tld])

    assert_equal [{ n: 'displayName', _content: 'Jane' }], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    assert_equal 'Jane', account.displayName
  end

  def test_update_without_difference_sends_no_request
    account = find_account(description: 'same', zimbraMailQuota: '1024', zimbraMailForwardingAddress: 'a@d.tld')

    refute account.update!(description: 'same', zimbraMailQuota: '1024', zimbraMailForwardingAddress: %w[a@d.tld])
    assert_nil @fake.last_request(:ModifyAccountRequest)
  end

  def test_update_with_force_sends_all_values
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'same')

    assert account.update!(description: 'same', force: true)

    assert_equal [{ n: 'description', _content: 'same' }], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
  end

  def test_update_sends_value_pending_in_a_setter_and_forgets_its_change
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'old')
    account.description = 'new'
    account.displayName = 'John'

    assert account.update!(description: 'new')

    assert_equal [{ n: 'description', _content: 'new' }], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
    assert_equal [:displayName], account.zimbra_attrs_changed
  end

  def test_update_sends_keys_that_are_not_zimbra_attributes_without_reading_them
    account = find_account
    account.define_singleton_method(:dangerous!) { raise 'called' }

    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })

    assert account.update!({ dangerous!: 'x' }, update_attributes: false)
    assert_equal [{ n: 'dangerous!', _content: 'x' }], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
  end

  def test_modify_clears_attributes_set_to_nil_or_empty
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(description: 'old', zimbraMailForwardingAddress: %w[a@d.tld])

    account.description = nil
    account.zimbraMailForwardingAddress = []
    account.modify!

    assert_equal [
      { n: 'description', _content: '' },
      { n: 'zimbraMailForwardingAddress', _content: '' }
    ], attr_nodes(@fake.last_request(:ModifyAccountRequest).body)
  end

  def test_will_change_tracks_in_place_mutation
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
    account = find_account(zimbraMailForwardingAddress: %w[a@d.tld b@d.tld])

    account.zimbraMailForwardingAddress << 'c@d.tld'
    refute account.zimbra_attrs_changed?

    assert_same account, account.zimbra_attr_will_change!(:zimbraMailForwardingAddress)
    account.modify!

    contents = attr_nodes(@fake.last_request(:ModifyAccountRequest).body).map { |node| node[:_content] }
    assert_equal %w[a@d.tld b@d.tld c@d.tld], contents
  end

  def test_will_change_rejects_readonly_and_unknown_attributes
    account = find_account

    assert_raises(ArgumentError) { account.zimbra_attr_will_change!(:zimbraId) }
    assert_raises(ArgumentError) { account.zimbra_attr_will_change!(:unknownAttribute) }
    refute account.zimbra_attrs_changed?
  end

  def test_create_sends_all_set_attributes_and_clears_changes
    @fake.on(:CreateAccountRequest) do |request|
      { CreateAccountResponse: { account: [ZmTest::FakeData.account(name: request.body[:name], id: 'new-id')] } }
    end
    account = @cluster.accounts.new
    account.name = 'new@domain.tld'
    account.instance_variable_set(:@displayName, 'set without setter')
    account.description = 'created'
    account.create!

    nodes = attr_nodes(@fake.last_request(:CreateAccountRequest).body)
    assert_includes nodes, { n: 'displayName', _content: 'set without setter' }
    assert_includes nodes, { n: 'description', _content: 'created' }
    refute account.zimbra_attrs_changed?
  end

  def test_quota_limit_is_not_a_change
    json = ZmTest::FakeData.account(name: 'user@domain.tld').merge(limit: 1024, used: 10)
    account = Zm::Client::AccountJsnsInitializer.create(@cluster, json)

    assert_equal 1024, account.zimbraMailQuota
    refute account.zimbra_attrs_changed?
  end

  def test_clone_and_inspect_ignore_changes
    account = find_account
    account.description = 'new'

    copy = account.clone
    copy.displayName = 'copy'

    assert_equal [:description], account.zimbra_attrs_changed
    assert_equal [:displayName], copy.zimbra_attrs_changed
    refute_includes account.inspect, 'zimbra_attrs_changes'
  end

  def test_cos_modify_sends_changed_attributes_only
    cos_json = ZmTest::FakeData.account(name: 'default', id: 'cos-id', zimbraMailQuota: '10', zimbraMailHostPool: 'h1')
    @fake.on(:GetCosRequest, { GetCosResponse: { cos: [cos_json] } })
    @fake.on(:ModifyCosRequest, { ModifyCosResponse: { cos: [] } })
    cos = @cluster.coses.find_by(name: 'default')

    refute cos.zimbra_attrs_changed?
    refute cos.modify!
    assert cos.modify!(force: true)
    assert_includes attr_nodes(@fake.last_request(:ModifyCosRequest).body), { n: 'zimbraMailQuota', _content: 10 }

    cos.zimbraMailQuota = 20
    assert cos.modify!

    assert_equal [{ n: 'zimbraMailQuota', _content: 20 }], attr_nodes(@fake.last_request(:ModifyCosRequest).body)
  end

  def test_distribution_list_save_sends_changed_attributes_only
    dl_json = ZmTest::FakeData.account(name: 'list@domain.tld', id: 'dl-id', description: 'old',
                                       zimbraMailStatus: 'enabled')
    @fake.on(:GetDistributionListRequest, { GetDistributionListResponse: { dl: [dl_json] } })
    @fake.on(:ModifyDistributionListRequest, { ModifyDistributionListResponse: { dl: [] } })
    dl = @cluster.distribution_lists.find_by(name: 'list@domain.tld')

    refute dl.zimbra_attrs_changed?

    dl.description = 'new'
    assert dl.save!

    assert_equal [{ n: 'description', _content: 'new' }],
                 attr_nodes(@fake.last_request(:ModifyDistributionListRequest).body)
  end

  private

  def find_account(**attributes)
    json = ZmTest::FakeData.account(name: 'user@domain.tld', id: 'a1b2', **attributes)
    @fake.on(:GetAccountRequest, { GetAccountResponse: { account: [json] } })
    @cluster.accounts.find_by(name: 'user@domain.tld')
  end
end
