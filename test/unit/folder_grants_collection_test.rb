# frozen_string_literal: true

require_relative '../test_helper'

class FolderGrantsCollectionTest < ZmTest::UnitTest
  ROOT = { id: '1', name: 'USER_ROOT', folder: [
    { id: '10', name: 'Calendar', view: 'appointment', acl: { grant: [
      { zid: 'account-1', gt: 'usr', perm: 'r' },
      { zid: 'dl-1', gt: 'grp', perm: 'rw' },
      { zid: 'domain-1', gt: 'dom', perm: 'r' },
      { zid: 'account-2', gt: 'usr', perm: 'rwidx' },
      { gt: 'pub', perm: 'r' },
      { zid: 'guest@external.tld', gt: 'guest', perm: 'r' },
      { zid: 'key-1', gt: 'key', perm: 'r' }
    ] } }
  ] }.freeze

  def setup
    super
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [ROOT] } })
    @grants = logged_account.folders.all.find { |folder| folder.id == '10' }.grants
  end

  def test_grants_by_grantee_type
    assert_equal %w[account-1 account-2], @grants.accounts.map(&:zid)
    assert_equal %w[dl-1], @grants.distribution_lists.map(&:zid)
    assert_equal %w[domain-1], @grants.domains.map(&:zid)
    assert_equal %w[pub], @grants.publics.map(&:gt)
    assert_equal %w[guest@external.tld], @grants.externals.map(&:zid)
    assert_equal %w[key-1], @grants.keys.map(&:zid)
  end

  def test_grant_created_from_a_resource_is_an_account_grant
    resource = Zm::Client::Resource.new(logged_cluster) { |r| r.id = 'resource-1' }

    @grants.create_from_object(resource, 'r')

    assert_equal %w[account-1 account-2 resource-1], @grants.accounts.map(&:zid)
  end

  def test_folder_without_grant
    grants = Zm::Client::Folder.new(logged_account) { |folder| folder.id = '20' }.grants

    assert_empty grants.accounts
    assert_empty grants.keys
  end
end
