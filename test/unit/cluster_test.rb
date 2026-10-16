# frozen_string_literal: true

require_relative '../test_helper'

class ClusterTest < ZmTest::UnitTest
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

  def test_login_propagates_network_errors
    @fake.network_error(:AuthRequest)

    assert_raises(Faraday::ConnectionFailed) { Zm::Client::Cluster.new(build_config).login }
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
