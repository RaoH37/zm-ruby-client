# frozen_string_literal: true

require_relative '../test_helper'

class ObjectsTest < Minitest::Test
  def test_recipient_display_name_is_nil_when_not_set
    recipient = Zm::Client::Recipient.new('t', 'user@domain.tld')

    assert_nil recipient.display_name
    assert_equal :t, recipient.field
  end

  def test_message_recipients_filter_by_field
    recipients = Zm::Client::MessageRecipients.new
    recipients.add(Zm::Client::Recipient.new(:t, 'to@domain.tld'))
    recipients.add(Zm::Client::Recipient.new(:c, 'cc@domain.tld'))
    recipients.add(Zm::Client::Recipient.new(:f, 'from@domain.tld', 'Sender'))
    recipients.add('not a recipient')

    assert_equal 3, recipients.all.size
    assert_equal ['to@domain.tld'], recipients.to.map(&:email)
    assert_equal ['cc@domain.tld'], recipients.cc.map(&:email)
    assert_empty recipients.bcc
    assert_equal ['Sender'], recipients.from.map(&:display_name)
  end

  def test_search_folder_accessors
    search_folder = Zm::Client::SearchFolder.allocate
    search_folder.name = 'unread'
    search_folder.query = 'is:unread'
    search_folder.sortBy = 'dateDesc'

    assert_equal %w[unread is:unread dateDesc], [search_folder.name, search_folder.query, search_folder.sortBy]
  end

  def test_base_jsns_builder_patch_splits_multi_valued_attributes
    builder = Zm::Client::Base::BaseJsnsBuilder.new(Struct.new(:id).new('42'))

    jsns = builder.to_patch({ cn: 'name', mail: %w[a@domain.tld b@domain.tld] })

    assert_equal({ id: '42', a: [{ n: :cn, _content: 'name' },
                                 { n: :mail, _content: 'a@domain.tld' },
                                 { n: :mail, _content: 'b@domain.tld' }] }, jsns)
  end

  def test_token_metadatas
    token = Zm::Client::Token.new(ZmTest::FakeData.token(id: 'abc', admin: false, expires_in: 60))

    assert_equal 'abc', token.zimbra_id
    refute token.admin?
    refute token.expired?
    assert_equal '10.1.0', token.server_version
  end

  def test_token_metadatas_ignore_malformed_parts
    encoded = 'id=3:abc;broken;exp=1:0'.unpack1('H*')
    token = Zm::Client::Token.new("0_hmac_#{encoded}")

    assert_equal 'abc', token.zimbra_id
    assert_nil token.metadatas['broken']
  end

  def test_format_email_does_not_mutate_argument
    email = +' John@Domain.TLD '

    assert_equal 'john@domain.tld', Zm::Client::Utils.format_email(email)
    assert_equal ' John@Domain.TLD ', email
    assert_equal 'john@domain.tld', Zm::Client::Utils.format_email('John@domain.tld')
  end

  def test_format_email_rejects_invalid_values
    [nil, :symbol, 42, '', '   '].each do |value|
      assert_raises(ArgumentError) { Zm::Client::Utils.format_email(value) }
    end
  end
end
