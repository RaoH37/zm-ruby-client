# frozen_string_literal: true

require_relative '../test_helper'

class ContactMembersCollectionTest < ZmTest::UnitTest
  SHARED_ID = 'f3a1b2c4-0000-4000-8000-000000000001'

  def setup
    super
    json = {
      id: '257', l: '7', fileAsStr: 'Team', _attrs: { type: 'group', nickname: 'Team' },
      m: [
        { type: 'C', value: '300' },
        { type: 'C', value: "#{SHARED_ID}:301" },
        { type: 'I', value: 'free@domain.tld' },
        { type: 'G', value: 'uid=john,ou=people,dc=domain,dc=tld' }
      ]
    }
    @members = Zm::Client::ContactJsnsInitializer.create(logged_account, json).members
  end

  def test_members_by_type
    assert_equal [300, 301], @members.internals.map(&:value)
    assert_equal [SHARED_ID], @members.shared.map(&:shared_account_id)
    assert_equal %w[free@domain.tld], @members.frees.map(&:value)
    assert_equal %w[john@domain.tld], @members.ldaps.map(&:email_address)
  end

  def test_added_members_are_selected
    @members.add(Zm::Client::ContactMember.new('I', 'new@domain.tld'))

    assert_equal %w[free@domain.tld new@domain.tld], @members.frees.map(&:value)
  end

  def test_array_methods_are_delegated_to_all
    assert_equal 4, @members.length
    assert_equal %w[C C I G], @members.map(&:type)
  end
end
