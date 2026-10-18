# frozen_string_literal: true

require_relative '../test_helper'

class ContactTest < ZmTest::UnitTest
  def build_contact
    account = logged_account
    folder = account.folders.new { |f| f.id = 300 }
    contact = account.contacts.new do |ct|
      ct.firstName = 'Live'
      ct.email = 'contact@domain.tld'
      ct.folder = folder
    end
    contact.id = 257
    contact.tags
    contact
  end

  def contact_attrs(soap_request)
    soap_request.to_hash.values.first[:cn][:a].to_h { |a| [a[:n], a[:_content]] }
  end

  def test_create_sends_only_contact_attributes
    jsns = build_contact.jsns_builder.to_jsns

    assert_equal({ 'firstName' => 'Live', 'email' => 'contact@domain.tld' }, contact_attrs(jsns))
    assert_equal '300', jsns.to_hash.values.first[:cn][:l]
  end

  def test_update_sends_only_contact_attributes
    contact = build_contact
    contact.jobTitle = 'Tester'

    assert_equal({ 'firstName' => 'Live', 'email' => 'contact@domain.tld', 'jobTitle' => 'Tester' },
                 contact_attrs(contact.jsns_builder.to_update))
  end

  def test_create_keeps_custom_properties
    contact = build_contact
    contact.add_custom_property('myKey', 'myValue')

    assert_equal 'myValue', contact_attrs(contact.jsns_builder.to_jsns)['myKey']
  end
end

class GroupContactTest < ZmTest::UnitTest
  def new_group
    contact = logged_account.contacts.new do |ct|
      ct.name = 'Team'
      ct.type = Zm::Client::Contact::GROUP_PATTERN
    end
    contact.extend(Zm::Client::ModGroupContact)
  end

  def loaded_group
    json = {
      id: '257', l: '7', fileAsStr: 'Team',
      _attrs: { type: 'group', nickname: 'Team' },
      m: [{ type: 'C', value: '300' }, { type: 'I', value: 'old@domain.tld' }]
    }
    Zm::Client::ContactJsnsInitializer.create(logged_account, json)
  end

  def cn(soap_request)
    soap_request.to_hash.values.first[:cn]
  end

  def test_create
    group = new_group
    group.members.add(Zm::Client::ContactMember.new('I', 'member@domain.tld'))
    jsns = group.jsns_builder.to_create

    assert_equal 'CreateContactRequest', jsns.to_hash.keys.first
    assert_equal '7', cn(jsns)[:l]
    assert_equal [{ type: 'I', value: 'member@domain.tld' }], cn(jsns)[:m]
    assert_includes cn(jsns)[:a], { n: :type, _content: :group }
  end

  def test_create_in_folder
    group = new_group
    group.l = 300

    assert_equal '300', cn(group.jsns_builder.to_create)[:l]
  end

  def test_update_sends_only_changed_members
    group = loaded_group
    group.members.add(Zm::Client::ContactMember.new('I', 'new@domain.tld'))
    group.members.remove(Zm::Client::ContactMember.new('I', 'old@domain.tld'))
    jsns = group.jsns_builder.to_update

    assert_equal 'ModifyContactRequest', jsns.to_hash.keys.first
    assert_equal '257', cn(jsns)[:id]
    assert_equal [{ type: 'I', value: 'old@domain.tld', op: '-' }, { type: 'I', value: 'new@domain.tld', op: '+' }],
                 cn(jsns)[:m]
  end

  def test_patch
    jsns = loaded_group.jsns_builder.to_patch({ nickname: 'New Team' })

    assert_equal({ id: '257', a: [{ n: :nickname, _content: 'New Team' }] }, cn(jsns))
  end
end
