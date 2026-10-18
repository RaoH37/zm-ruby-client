# frozen_string_literal: true

require_relative '../test_helper'

class MessagesTest < ZmTest::UnitTest
  def setup
    super
    @account = logged_account
  end

  def test_secure_find_each_stops_on_request_error
    @fake.fault(:SearchRequest, code: 'service.FAILURE')

    count = 0
    @account.messages.find_each { count += 1 }

    assert_equal 0, count
    assert_equal(1, @fake.requests.count { |r| r.name == 'SearchRequest' })
  end

  def test_secure_find_each_continues_after_block_error
    @fake.on(:SearchRequest) do |request|
      more = request.body[:offset].to_i.zero?
      { SearchResponse: { m: [message_json(request.body[:offset])], more: } }
    end

    ids = []
    @account.messages.find_each(limit: 1) do |message|
      ids << message.id
      raise 'boom' if ids.size == 1
    end

    assert_equal %w[0 1], ids
  end

  def test_unsecure_find_each_raises_request_error
    @fake.fault(:SearchRequest, code: 'service.FAILURE')

    assert_raises(Zm::Error::SoapError) { @account.messages.find_each(secure: false) { nil } }
  end

  private

  def message_json(id)
    { id: id.to_s, e: [], su: "subject #{id}" }
  end
end
