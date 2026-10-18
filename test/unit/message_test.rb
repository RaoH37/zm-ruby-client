# frozen_string_literal: true

require_relative '../test_helper'

class MessageTest < ZmTest::UnitTest
  def test_attachment_belongs_to_message
    json = {
      id: '257', e: [],
      mp: [{ cd: 'attachment', ct: 'application/pdf', part: '2', filename: 'doc.pdf', s: 1024 }]
    }
    account = Zm::Client::Account.new(nil)
    message = Zm::Client::MessageJsnsInitializer.create(account, json)
    attachment = message.attachments.all.first

    assert_instance_of Zm::Client::Attachment, attachment
    assert_equal '2', attachment.part
    assert_same account, attachment.account
  end

  def test_download_attachment_url
    upload = Zm::Client::Upload.new('https://mail.domain.tld:443/home/user@domain.tld', 'token')

    assert_equal 'https://mail.domain.tld:443/home/user@domain.tld?id=257&part=2&charset=UTF-8&auth=co&emptyname=Empty&disp=a',
                 upload.download_attachment_url('257', '2')
  end

  def test_flag_actions_use_account_connector
    @fake.on(:ItemActionRequest, { ItemActionResponse: { action: { id: '257' } } })
    message = logged_account.messages.new { |m| m.id = '257' }

    message.flags.flag!
    message.flags.unread!

    actions = @fake.requests.select { |r| r.name == 'ItemActionRequest' }.map { |r| r.body[:action] }
    assert_equal [{ op: 'flag', id: '257' }, { op: '!read', id: '257' }], actions
  end

  def test_flag_actions_update_local_flags
    @fake.on(:ItemActionRequest, { ItemActionResponse: { action: { id: '257' } } })
    message = logged_account.messages.new do |m|
      m.id = '257'
      m.f = 'ua'
    end

    message.flags.flag!
    assert_predicate message.flags, :flagged?
    assert_equal 'uaf', message.f

    message.flags.read!
    refute_predicate message.flags, :unread?
    assert_equal 'af', message.f

    message.flags.unread!
    message.flags.unread!
    assert_equal 'afu', message.f

    message.flags.unflag!
    refute_predicate message.flags, :flagged?
    assert_equal 'au', message.f
  end
end
