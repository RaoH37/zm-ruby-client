# frozen_string_literal: true

require_relative 'live_helper'

class AccountFoldersLiveTest < ZmTest::LiveTest
  def create_folder(name = unique_name('folder'), **attrs)
    folder = account.folders.new do |f|
      f.name = name
      f.color = 4
      attrs.each { |key, value| f.public_send(:"#{key}=", value) }
    end
    folder.create!
    folder
  end

  def find_folder(id)
    account.folders.all!.find { |f| f.id.to_s == id.to_s }
  end

  def test_default_folders
    ids = account.folders.all.map { |f| f.id.to_i }

    assert_includes ids, Zm::Client::FolderDefault::INBOX.id
    assert_includes ids, Zm::Client::FolderDefault::CALENDAR.id
    assert_includes ids, Zm::Client::FolderDefault::CONTACTS.id
  end

  def test_find
    inbox = account.folders.find(Zm::Client::FolderDefault::INBOX.id)

    assert_equal Zm::Client::FolderDefault::INBOX.name, inbox.name
    assert_predicate inbox, :is_immutable?
  end

  def test_create
    name = unique_name('folder')
    folder = create_folder(name, view: Zm::Client::FolderDefault::CALENDAR.type)

    refute_nil folder.id
    found = account.folders.find(folder.id)
    assert_equal name, found.name
    assert_equal Zm::Client::FolderDefault::CALENDAR.type, found.view
    assert_equal 4, found.color.to_i
  end

  def test_create_subfolder
    parent = create_folder
    child = create_folder(folder: parent)
    found = account.folders.find(child.id)

    assert_equal parent.id.to_s, found.l.to_s
    assert_equal "/#{parent.name}/#{child.name}", found.absFolderPath
  end

  def test_create_with_existing_name_raises
    folder = create_folder
    duplicate = account.folders.new { |f| f.name = folder.name }

    assert_raises(Zm::Error::SoapError) { duplicate.create! }
  end

  def test_where_view
    contact_folder = create_folder(view: Zm::Client::FolderDefault::CONTACTS.type)
    message_folder = create_folder(view: Zm::Client::FolderDefault::INBOX.type)
    ids = account.folders.contact.all.map { |f| f.id.to_s }

    assert_includes ids, contact_folder.id.to_s
    refute_includes ids, message_folder.id.to_s
  end

  def test_modify
    folder = create_folder
    folder.color = 5

    assert folder.modify!
    assert_equal 5, account.folders.find(folder.id).color.to_i
  end

  def test_update
    folder = create_folder

    assert folder.update!({ color: 3 })
    assert_equal 3, folder.color
    assert_equal 3, account.folders.find(folder.id).color.to_i
  end

  def test_rename
    folder = create_folder
    new_name = unique_name('renamed')
    folder.rename!(new_name)

    assert_equal new_name, account.folders.find(folder.id).name
  end

  def test_move
    parent = create_folder
    folder = create_folder
    folder.move!(parent.id)

    assert_equal parent.id.to_s, account.folders.find(folder.id).l.to_s
  end

  def test_add_message_and_empty
    folder = create_folder(view: Zm::Client::FolderDefault::INBOX.type)
    folder.add_message(eml)
    folder.reload!

    assert_equal 1, folder.nb_items.to_i

    folder.empty!
    folder.reload!

    assert_predicate folder, :empty?
  end

  def test_delete
    folder = create_folder
    folder.delete!

    assert_nil find_folder(folder.id)
  end

  def test_delete_immutable_folder_is_refused
    refute account.folders.find(Zm::Client::FolderDefault::INBOX.id).delete!
  end
end
