# frozen_string_literal: true

require_relative 'integration_helper'

class FolderIntegrationTest < ZmTest::IntegrationTest
  INBOX_ID = 2

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new(CONFIG_PATH))
    @admin.login

    @account = @admin.accounts.find_by name: fixture(:accounts).dig('accounts', 'maxime', 'email')
    @created_folders = []
  end

  def teardown
    @created_folders.each do |folder|
      folder.delete!
    rescue Zm::Error::SoapError
      nil
    end
  end

  def test_all
    assert_kind_of Array, @account.folders.all
  end

  def test_find
    assert_equal INBOX_ID, @account.folders.find(INBOX_ID).id.to_i
  end

  def test_create
    folder = create_folder

    refute_nil folder.id
    refute_nil find_folder(folder.id)
  end

  def test_create_with_existing_name_raises
    folder = create_folder

    duplicate = @account.folders.new { |f| f.name = folder.name }
    assert_raises(Zm::Error::SoapError) { duplicate.create! }
  end

  def test_modify
    folder = create_folder(color: 1)
    folder.color = 5

    assert folder.modify!
    assert_equal 5, find_folder(folder.id).color.to_i
  end

  def test_update
    folder = create_folder(color: 1)

    assert folder.update!({ color: 3 })
    assert_equal 3, folder.color
    assert_equal 3, find_folder(folder.id).color.to_i
  end

  def test_color
    folder = create_folder(color: 1)
    folder.color = 2

    assert folder.color!
  end

  def test_reload
    folder = create_folder
    id = folder.id
    folder.reload!

    assert_equal id, folder.id
  end

  def test_move
    parent = create_folder
    folder = create_folder

    folder.move!(parent.id)

    assert_equal parent.id.to_s, find_folder(folder.id).l.to_s
  end

  def test_empty
    folder = create_folder
    folder.empty!

    assert_predicate folder.nb_items.to_i, :zero?
  end

  def test_delete
    folder = create_folder
    folder.delete!
    @created_folders.delete(folder)

    assert_nil find_folder(folder.id)
  end

  def test_delete_immutable_folder_is_refused
    refute @account.folders.find(INBOX_ID).delete!
  end

  def test_rename
    folder = create_folder
    new_name = unique_name('folder-renamed')

    folder.rename!(new_name)

    assert_equal new_name, find_folder(folder.id).name
  end

  private

  def create_folder(color: 4)
    folder = @account.folders.new do |f|
      f.name = unique_name('folder')
      f.color = color
    end
    folder.create!
    @created_folders.unshift(folder)
    folder
  end

  def find_folder(id)
    @account.folders.all!.find { |f| f.id.to_s == id.to_s }
  end
end
