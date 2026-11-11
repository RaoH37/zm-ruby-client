# frozen_string_literal: true

require_relative '../test_helper'

class FolderRetentionPoliciesCollectionTest < ZmTest::UnitTest
  def setup
    super
    @policies = Zm::Client::Folder.new(logged_account) { |folder| folder.id = '2' }.retention_policies
  end

  def test_keeps_and_purges
    @policies.create(:keep, '30d', :user)
    @policies.create(:purge, '365d', :user)
    @policies.create(:keep, '90d', :system)

    assert_equal %w[30d 90d], @policies.keeps.map(&:lifetime)
    assert_equal %w[365d], @policies.purges.map(&:lifetime)
  end

  def test_folder_without_retention_policy
    assert_empty @policies.keeps
    assert_empty @policies.purges
  end

  def test_policies_created_with_strings
    @policies.create('keep', '30d', 'user')
    @policies.create('purge', '365d', 'user')

    assert_equal %w[30d], @policies.keeps.map(&:lifetime)
    assert_equal %w[365d], @policies.purges.map(&:lifetime)
  end

  def test_policies_are_loaded_from_get_folder_response
    policies = load_folder(retentionPolicy: [{
                             keep: [{ policy: [{ lifetime: '30d', type: 'user' }] }],
                             purge: [{ policy: [{ lifetime: '365d', type: 'user' }] }]
                           }]).retention_policies

    assert_equal([[:keep, '30d', 'user']], policies.keeps.map { |rp| policy_values(rp) })
    assert_equal([[:purge, '365d', 'user']], policies.purges.map { |rp| policy_values(rp) })
  end

  def test_empty_policies_from_get_folder_response_are_skipped
    policies = load_folder(retentionPolicy: [{ keep: [{}], purge: [] }]).retention_policies

    assert_empty policies.all
  end

  def test_folder_without_retention_policy_in_get_folder_response
    assert_empty load_folder.retention_policies.all
  end

  private

  def policy_values(retention_policy)
    [retention_policy.policy, retention_policy.lifetime, retention_policy.type]
  end

  def load_folder(**attributes)
    root = { id: '1', name: 'USER_ROOT', folder: [{ id: '2', name: 'Inbox', view: 'message', **attributes }] }
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [root] } })
    logged_account.folders.all.find { |folder| folder.id == '2' }
  end
end
