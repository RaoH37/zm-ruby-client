# frozen_string_literal: true

require_relative '../test_helper'

class FoldersCollectionTest < ZmTest::UnitTest
  ROOT = { id: '1', name: 'USER_ROOT', folder: [
    { id: '2', name: 'Inbox', view: 'message', folder: [
      { id: '257', name: 'projects', view: 'message' }
    ] },
    { id: '10', name: 'Calendar', view: 'appointment' },
    { id: '16', name: 'Briefcase', view: 'document' }
  ] }.freeze

  def setup
    super
    @account = logged_account
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [ROOT] } })
  end

  def test_view_is_sent_and_filters_the_folders
    folders = @account.folders.appointment.all

    assert_equal 'appointment', @fake.last_request(:GetFolderRequest).body[:view]
    assert_equal %w[10], folders.map(&:id)
  end

  def test_where_view_filters_the_folders
    assert_equal %w[2 257], @account.folders.where(view: 'message').all.map(&:id)
  end

  def test_query_params_are_reset_after_the_request
    collection = @account.folders
    collection.appointment.all

    assert_nil collection.view
    assert_equal %w[1 2 257 10 16], collection.all.map(&:id)
    assert_nil @fake.last_request(:GetFolderRequest).body[:view]
  end

  def test_clear_is_public_and_resets_the_query_params
    collection = @account.folders.where(view: 'message', tr: true)
    collection.depth = 1

    assert_nil collection.clear
    assert_nil collection.view
    assert_nil collection.tr
    assert_nil collection.depth
    assert_nil @fake.last_request(:GetFolderRequest)
  end

  def test_ids_lists_every_folder_under_the_root
    ids = @account.folders.ids

    assert_equal %w[2 257 10 16], ids.map(&:item_id)
    assert_equal [nil], ids.map(&:mailbox_id).uniq
  end

  def test_ids_reads_the_mailbox_id_of_a_remote_folder
    root = { id: '1', name: 'USER_ROOT', folder: [{ id: 'f3a1b2c4-0000-4000-8000-000000000001:257', name: 'shared' }] }
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [root] } })

    ids = @account.folders.ids

    assert_equal [Zm::Client::MailboxItemID.new('257', 'f3a1b2c4-0000-4000-8000-000000000001')], ids
  end

  def test_tree_returns_the_root_with_its_children
    root = @account.folders.tree

    assert_instance_of Zm::Client::Folder, root
    assert_equal '1', root.id
    assert_equal %w[2 10 16], root.folders.map(&:id)
    assert_equal %w[257], root.folders.first.folders.map(&:id)
    assert_equal '/Inbox/projects', root.folders.first.folders.first.absFolderPath
  end
end
