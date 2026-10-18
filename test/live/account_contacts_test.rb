# frozen_string_literal: true

require_relative 'live_helper'

class AccountContactsLiveTest < ZmTest::LiveTest
  def create_contact(**attrs)
    contact = account.contacts.new do |ct|
      ct.firstName = 'Live'
      ct.lastName = 'Test'
      ct.email = unique_email('contact')
      attrs.each { |key, value| ct.public_send(:"#{key}=", value) }
    end
    contact.create!
    contact
  end

  def find_contact(id, folder_id = Zm::Client::FolderDefault::CONTACTS.id)
    account.contacts.folder_ids(folder_id).all.find { |ct| ct.id.to_s == id.to_s }
  end

  def test_create
    contact = create_contact

    refute_nil contact.id
    refute_nil find_contact(contact.id)
  end

  def test_read
    contact = create_contact(company: 'Live Corp')
    found = find_contact(contact.id)

    assert_kind_of Zm::Client::Contact, found
    assert_equal 'Live', found.firstName
    assert_equal 'Test', found.lastName
    assert_equal contact.email, found.email
    assert_equal 'Live Corp', found.company
  end

  def test_create_in_folder
    folder = account.folders.new do |f|
      f.name = unique_name('contacts')
      f.view = Zm::Client::FolderDefault::CONTACTS.type
    end
    folder.create!
    contact = create_contact(folder:)

    assert_equal folder.id.to_s, find_contact(contact.id, folder.id).l.to_s
  end

  def test_modify
    contact = create_contact
    contact.jobTitle = 'Tester'

    assert contact.modify!
    assert_equal 'Tester', find_contact(contact.id).jobTitle
  end

  def test_update
    contact = create_contact
    email3 = unique_email('email3')

    assert contact.update!({ email3: })
    assert_equal email3, contact.email3
    assert_equal email3, find_contact(contact.id).email3
  end

  def test_move
    folder = account.folders.new do |f|
      f.name = unique_name('contacts')
      f.view = Zm::Client::FolderDefault::CONTACTS.type
    end
    folder.create!
    contact = create_contact
    contact.move!(folder.id)

    assert_nil find_contact(contact.id)
    refute_nil find_contact(contact.id, folder.id)
  end

  def test_tags
    tag = account.tags.new { |t| t.name = unique_name('tag') }
    tag.create!
    contact = create_contact

    assert contact.tags.add!(tag.name)
    assert_includes find_contact(contact.id).tags.all, tag.name

    contact.tags.remove!(tag.name)
    refute_includes find_contact(contact.id).tags.all, tag.name
  end

  def test_create_group
    contact = create_contact
    group = account.contacts.new do |ct|
      ct.name = unique_name('group')
      ct.type = Zm::Client::Contact::GROUP_PATTERN
    end
    group.extend(Zm::Client::ModGroupContact)
    group.members.add(Zm::Client::ContactMember.new(Zm::Client::ContactMember::FREE, 'free@example.com'))
    group.members.add(Zm::Client::ContactMember.new(Zm::Client::ContactMember::INTERNAL, contact.id))
    group.create!

    refute_nil group.id
    assert_predicate find_contact(group.id), :group?
  end

  def test_delete
    contact = create_contact
    contact.delete!

    assert_nil find_contact(contact.id)
  end
end
