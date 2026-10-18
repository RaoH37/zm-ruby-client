# frozen_string_literal: true

require_relative '../test_helper'

class AdminContextTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
    @account = @cluster.accounts.new do |a|
      a.id = 'account-id'
      a.name = 'user@domain.tld'
    end
  end

  def test_delegated_account_connector_does_not_change_cluster_context
    @account.soap_connector

    assert_nil @cluster.soap_admin_connector.context.to_hash[:account]
    assert_equal({ by: :id, _content: 'account-id' }, @account.soap_connector.context.to_hash[:account])
  end

  def test_cluster_requests_have_no_account_header_after_delegated_request
    @fake.on(:GetTagRequest, { GetTagResponse: {} })
    @fake.on(:NoOpRequest, { NoOpResponse: {} })

    @account.tags.all
    @cluster.alive?

    delegated_header = @fake.last_request(:GetTagRequest).header.dig(:context, :account)
    assert_equal({ by: 'id', _content: 'account-id' }, delegated_header)
    assert_nil @fake.last_request(:NoOpRequest).header.dig(:context, :account)
  end

  def test_delegated_account_connector_follows_cluster_token
    @account.soap_connector
    new_token = ZmTest::FakeData.token
    @cluster.token = new_token

    assert_equal new_token, @account.soap_connector.token
  end

  def test_server_mailboxes_resets_target_server
    @fake.on(:GetAllMailboxesRequest, { GetAllMailboxesResponse: { mbox: [] } })
    server = Zm::Client::Server.new(@cluster) { |s| s.id = 'server-id' }

    server.mailboxes

    assert_equal 'server-id', @fake.last_request(:GetAllMailboxesRequest).header.dig(:context, :targetServer)
    assert_nil @cluster.soap_admin_connector.context.to_hash[:targetServer]
  end

  def test_quotas_resets_target_server_on_error
    @fake.fault(:GetQuotaUsageRequest, code: 'service.FAILURE')

    assert_raises(Zm::Error::SoapError) { @cluster.accounts.quotas(target_server_id: 'server-id') }
    assert_nil @cluster.soap_admin_connector.context.to_hash[:targetServer]
  end
end
