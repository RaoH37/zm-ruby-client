# frozen_string_literal: true

require_relative '../test_helper'

class MessageTest < ZmTest::UnitTest
  def test_attachment_belongs_to_message
    json = {
      id: '257', e: [],
      mp: [{ cd: 'attachment', ct: 'application/pdf', part: '2', filename: 'doc.pdf', s: 1024 }]
    }
    account = Object.new
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
end
