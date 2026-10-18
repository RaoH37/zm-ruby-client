# frozen_string_literal: true

require_relative '../test_helper'

class LogFilterTest < ZmTest::UnitTest
  def test_filters_request_secrets
    json = {
      Header: { context: { authToken: 'tok' } },
      Body: { AuthRequest: { password: 'p"wd', newPassword: 'new', preauth: { timestamp: 1, _content: 'hmac' },
                             a: [{ n: 'userPassword', _content: 'up' }, { n: 'cn', _content: 'John' }] } }
    }.to_json

    filtered = Zm::Utils::LogFilter.filter(json)

    %w[tok p\\"wd new hmac up].each { |secret| refute_includes filtered, "\"#{secret}\"" }
    assert_includes filtered, '"John"'
    assert_equal 5, filtered.scan('[FILTERED]').size
  end

  def test_filters_auth_response_token
    json = { Body: { AuthResponse: { authToken: [{ _content: 'tok' }], lifetime: 1 } } }.to_json

    refute_includes Zm::Utils::LogFilter.filter(json), 'tok'
  end

  def test_filters_auth_cookie
    assert_equal 'Cookie: "ZM_ADMIN_AUTH_TOKEN=[FILTERED]"',
                 Zm::Utils::LogFilter.filter('Cookie: "ZM_ADMIN_AUTH_TOKEN=0_abc_123"')
  end

  def test_debug_log_does_not_contain_credentials
    io = StringIO.new
    config = build_config
    config.log_path = io
    config.log_level = Logger::DEBUG
    auth_token = ZmTest::FakeData.token
    @fake.on(:AuthRequest, ZmTest::FakeData.auth_response(auth_token))

    Zm::Client::Cluster.new(config).login

    refute_includes io.string, ADMIN_PASSWORD
    refute_includes io.string, auth_token
    assert_includes io.string, 'AuthRequest'
  end
end
