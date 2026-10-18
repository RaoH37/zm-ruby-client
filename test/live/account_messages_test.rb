# frozen_string_literal: true

require_relative 'live_helper'

class AccountMessagesLiveTest < ZmTest::LiveTest
  def add_message(subject = unique_name('subject'), folder_id: Zm::Client::FolderDefault::INBOX.id)
    folder = account.folders.new { |f| f.id = folder_id }
    folder.add_message(eml(subject:)).dig(:AddMsgResponse, :m, 0, :id).to_s.split(':').last
  end

  def find_message(id)
    account.messages.find(id)
  end

  def create_folder
    folder = account.folders.new do |f|
      f.name = unique_name('folder')
      f.view = Zm::Client::FolderDefault::INBOX.type
    end
    folder.create!
    folder
  end

  def test_create
    refute_nil add_message
  end

  def test_read
    subject = unique_name('subject')
    message = find_message(add_message(subject))

    assert_kind_of Zm::Client::Message, message
    assert_equal subject, message.su
    assert_equal Zm::Client::FolderDefault::INBOX.id.to_s, message.l.to_s
    assert_includes message.recipients.to.map(&:email), 'recipient@example.com'
    assert_includes message.body.text, 'Live Test body'
  end

  def test_search
    subject = unique_name('subject')
    id = add_message(subject)
    ids = account.messages.where(%(subject:"#{subject}")).all.map { |m| m.id.to_s }

    assert_equal [id.to_s], ids
  end

  def test_search_by_folder
    folder = create_folder
    id = add_message(folder_id: folder.id)
    add_message

    ids = account.messages.folder_ids(folder.id).all.map { |m| m.id.to_s }

    assert_equal [id.to_s], ids
  end

  def test_flags
    message = find_message(add_message)

    message.flags.flag!
    assert_predicate message.flags, :flagged?
    assert_predicate find_message(message.id).flags, :flagged?

    message.flags.unflag!
    refute_predicate find_message(message.id).flags, :flagged?

    message.flags.unread!
    assert_predicate find_message(message.id).flags, :unread?

    message.flags.read!
    refute_predicate message.flags, :unread?
    refute_predicate find_message(message.id).flags, :unread?
  end

  def test_move
    folder = create_folder
    message = find_message(add_message)
    message.move!(folder.id)

    assert_equal folder.id.to_s, find_message(message.id).l.to_s
  end

  def test_update
    folder = create_folder
    message = find_message(add_message)
    message.update!({ l: folder.id })

    assert_equal folder.id.to_s, find_message(message.id).l.to_s
  end

  def test_tags
    tag = account.tags.new { |t| t.name = unique_name('tag') }
    tag.create!
    message = find_message(add_message)

    assert message.tags.add!(tag.name)
    assert_includes find_message(message.id).tags.all, tag.name

    message.tags.remove!(tag.name)
    refute_includes find_message(message.id).tags.all, tag.name
  end

  def test_trash
    message = find_message(add_message)
    message.trash!

    assert_equal Zm::Client::FolderDefault::TRASH.id.to_s, find_message(message.id).l.to_s
  end

  def test_delete
    message = find_message(add_message)
    message.delete!

    assert_raises(Zm::Error::SoapError) { find_message(message.id) }
  end
end
