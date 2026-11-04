# frozen_string_literal: true

require_relative '../test_helper'

class ClusterTest < ZmTest::UnitTest
  def test_count_object_accepts_symbol_and_string
    @fake.on(:CountObjectsRequest, { CountObjectsResponse: { num: 42 } })
    cluster = logged_cluster

    assert_equal 42, cluster.count_object(:account)
    assert_equal 42, cluster.count_object('calresource')
    assert_equal(%w[account calresource], @fake.requests.select { |r| r.name == 'CountObjectsRequest' }
                                                  .map { |r| r.body[:type] })
  end

  def test_count_object_rejects_unknown_type_before_any_request
    cluster = logged_cluster

    assert_raises(Zm::Error::ZmError) { cluster.count_object('mailbox') }
    assert_nil @fake.last_request(:CountObjectsRequest)
  end

  def test_count_object_rejects_nil
    skip 'calls are ill-typed on purpose' if ENV['RBS_TEST_TARGET']

    assert_raises(Zm::Error::ZmError) { logged_cluster.count_object(nil) }
  end

  def test_login_sends_credentials_and_stores_token
    auth_token = ZmTest::FakeData.token
    @fake.on(:AuthRequest, ZmTest::FakeData.auth_response(auth_token))

    cluster = Zm::Client::Cluster.new(build_config)
    cluster.login

    request = @fake.last_request(:AuthRequest)
    assert_equal ADMIN_LOGIN, request.body[:name]
    assert_equal ADMIN_PASSWORD, request.body[:password]
    assert_equal Zm::SoapRequest::SoapAdminConstants::ADMIN_SERVICE_URI, request.path
    assert_equal auth_token, cluster.token.to_s
    assert cluster.logged?
    assert cluster.token.admin?
  end

  def test_login_with_bad_credentials_raises_auth_error
    @fake.fault(:AuthRequest, code: 'account.AUTH_FAILED', reason: 'authentication failed')

    error = assert_raises(Zm::Error::AuthError) { Zm::Client::Cluster.new(build_config).login }
    assert_equal 'account.AUTH_FAILED', error.code
    assert_equal 'authentication failed', error.reason
  end

  def test_login_without_credentials_raises_before_any_request
    cluster = Zm::Client::Cluster.new(build_config(zimbra_admin_password: nil))

    assert_raises(Zm::Client::ClusterConfigError) { cluster.login }
    assert_empty @fake.requests
  end

  def test_login_raises_connection_error_on_network_errors
    [Faraday::ConnectionFailed.new('refused'), Faraday::TimeoutError.new('timeout'), Faraday::SSLError.new('cert')]
      .each do |network_error|
        @fake.network_error(:AuthRequest, network_error)

        error = assert_raises(Zm::Error::ConnectionError) { Zm::Client::Cluster.new(build_config).login }
        assert_instance_of network_error.class, error.cause
        assert_includes error.message, network_error.class.name
      end
  end

  def test_non_json_error_response_raises_soap_error
    @fake.on(:AuthRequest) { [502, '<html><title>Bad Gateway</title></html>'] }

    error = assert_raises(Zm::Error::AuthError) { Zm::Client::Cluster.new(build_config).login }
    assert_equal 'HTTP 502', error.reason
  end

  def test_target_invoke_resets_target_server_on_error
    cluster = logged_cluster
    @fake.fault(:NoOpRequest, code: 'service.FAILURE')
    soap_request = Zm::SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::NO_OP_REQUEST)

    assert_raises(Zm::Error::SoapError) { cluster.soap_admin_connector.target_invoke(soap_request, 'server-id') }
    assert_nil cluster.soap_admin_connector.context.to_hash[:targetServer]
  end

  def test_target_invoke_does_not_leak_the_target_server_between_threads
    cluster = logged_cluster
    connector = cluster.soap_admin_connector
    @fake.on(:NoOpRequest) do |request|
      sleep 0.001
      { NoOpResponse: { target: request.header.dig(:context, :targetServer) } }
    end
    soap_request = -> { Zm::SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::NO_OP_REQUEST) }

    results = Array.new(8) do |i|
      Thread.new do
        Array.new(10) do
          target = i.even? ? "server-#{i}" : nil
          response = target ? connector.target_invoke(soap_request.call, target) : connector.invoke(soap_request.call)
          [target, response[:NoOpResponse][:target]]
        end
      end
    end.flat_map(&:value)

    assert_equal 80, results.size
    results.each { |expected, sent| assert_equal expected, sent }
    assert_nil connector.context.to_hash[:targetServer]
  end

  def test_domain_key_is_read_once_per_domain
    cluster = logged_cluster
    @fake.on(:GetDomainRequest) do |request|
      name = request.body[:domain][:_content]
      { GetDomainResponse: { domain: [{ name:, id: name, a: [{ n: 'zimbraPreAuthKey', _content: "key-#{name}" }] }] } }
    end

    keys = %w[a.tld b.tld a.tld b.tld].map { |domain| cluster.domain_key(domain) }

    assert_equal %w[key-a.tld key-b.tld key-a.tld key-b.tld], keys
    assert_equal(2, @fake.requests.count { |r| r.name == 'GetDomainRequest' })

    cluster.clear_domain_keys.domain_key('a.tld')

    assert_equal(3, @fake.requests.count { |r| r.name == 'GetDomainRequest' })
  end

  def test_expired_token_is_not_logged
    cluster = Zm::Client::Cluster.new(build_config)
    cluster.token = ZmTest::FakeData.token(expires_in: -60)

    refute cluster.logged?
  end

  def test_alive_sends_no_op_with_token
    cluster = logged_cluster
    @fake.on(:NoOpRequest, { NoOpResponse: {} })

    assert cluster.alive?
    assert_equal cluster.token.to_s, @fake.last_request(:NoOpRequest).header.dig(:context, :authToken)
  end

  def test_alive_is_false_when_server_returns_fault
    cluster = logged_cluster
    @fake.fault(:NoOpRequest, code: 'service.AUTH_EXPIRED')

    refute cluster.alive?
  end
end
