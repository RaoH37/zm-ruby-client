# frozen_string_literal: true

require_relative 'live_helper'

class AccountsLiveTest < ZmTest::LiveTest
  def create_account(name = unique_email)
    account = cluster.accounts.new do |acc|
      acc.name = name
      acc.password = SecureRandom.alphanumeric(24)
      acc.displayName = 'Live Test'
    end
    account.save!
    track(account)
  end

  def find_account(id)
    cluster.accounts.attrs('displayName', 'description').find_by(id:)
  end

  def test_create
    name = unique_email
    account = create_account(name)

    refute_nil account.id
    assert_equal name, find_account(account.id).name
  end

  def test_read
    account = create_account
    found = find_account(account.id)

    assert_kind_of Zm::Client::Account, found
    assert_equal account.id, found.id
    assert_equal 'Live Test', found.displayName
    assert cluster.email_exist?(account.name)
  end

  def test_modify
    account = create_account
    account.displayName = 'Live Test modified'
    account.save!

    assert_equal 'Live Test modified', find_account(account.id).displayName
  end

  def test_update
    account = create_account

    assert account.update!(description: 'patched')
    assert_equal 'patched', account.description
    assert_equal 'patched', find_account(account.id).description
  end

  def test_rename
    account = create_account
    new_name = unique_email('renamed')
    account.rename!(new_name)

    assert_equal new_name, find_account(account.id).name
  end

  def test_delete
    account = create_account
    id = account.id
    account.delete!

    assert_nil account.id
    assert_nil cluster.accounts.find_by_or_nil(id:)
  end
end
