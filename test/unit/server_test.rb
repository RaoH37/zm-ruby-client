# frozen_string_literal: true

require_relative '../test_helper'

class ServerTest < ZmTest::UnitTest
  def setup
    super
    @server = Zm::Client::Server.new(logged_cluster) do |server|
      server.id = 'server-id'
      server.instance_variable_set(:@description, 'old')
    end
  end

  def test_update_sends_modify_server_request
    @fake.on(:ModifyServerRequest, { ModifyServerResponse: { server: [] } })

    assert @server.update!(description: 'new', zimbraServiceEnabled: %w[mailbox mta])

    body = @fake.last_request(:ModifyServerRequest).body
    assert_equal({ _content: 'server-id' }, body[:id])
    assert_equal [
      { n: 'description', _content: 'new' },
      { n: 'zimbraServiceEnabled', _content: 'mailbox' },
      { n: 'zimbraServiceEnabled', _content: 'mta' }
    ], attr_nodes(body)
    assert_equal 'new', @server.description
  end

  def test_update_without_difference_sends_no_request
    refute @server.update!(description: 'old')
    assert_nil @fake.last_request(:ModifyServerRequest)
  end
end
