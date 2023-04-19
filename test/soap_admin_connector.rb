# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../lib")

require './lib/zm/client'

class TestAccount < Minitest::Test
  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    @fixture_accounts = YAML.safe_load(File.read('./test/fixtures/accounts.yml'))
    @fixture_servers = YAML.safe_load(File.read('./test/fixtures/servers.yml'))
    @fixture_domains = YAML.safe_load(File.read('./test/fixtures/domains.yml'))
  end

  def test_login
    trans = Zm::Client::SoapAdminConnector.create(@config)
    trans.auth(@config.zimbra_admin_login, @config.zimbra_admin_password)
    assert !trans.token.nil?
  end

  def test_account
    trans = Zm::Client::SoapAdminConnector.create(@config)
    trans.auth(@config.zimbra_admin_login, @config.zimbra_admin_password)
    resp = trans.get_account(@fixture_accounts['accounts']['maxime']['email'])
    assert resp.is_a?(Hash)
  end

  def test_auth_json_by_attribute
    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::AUTH_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attribute('name', @config.zimbra_admin_login)
    request.add_attribute('password', @config.zimbra_admin_password)
    json = request.to_json
    puts json
    assert json.is_a?(String)
  end

  def test_auth_json_by_attributes
    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::AUTH_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attributes(name: @config.zimbra_admin_login, password: @config.zimbra_admin_password)
    json = request.to_json
    puts json
    assert json.is_a?(String)
  end

  def test_server_json
    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::GET_SERVER_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attribute('attrs', nil)
    server = Zm::Client::SoapElement.new('server', nil).add_attribute('by', 'name').add_content('mailstore.domain.com')
    request.add_node(server)
    json = request.to_json
    puts json
    assert json.is_a?(String)
  end

  def test_invoke
    trans = Zm::Client::SoapAdminConnector.create(@config)
    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::AUTH_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attributes(name: @config.zimbra_admin_login, password: @config.zimbra_admin_password)
    resp = trans.invoke(request, Zm::Client::AuthError)
    puts resp
    assert resp.is_a?(Hash)
  end

  def test_server_invoke
    trans = Zm::Client::SoapAdminConnector.create(@config)
    auth_request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::AUTH_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    auth_request.add_attributes(name: @config.zimbra_admin_login, password: @config.zimbra_admin_password)
    auth_resp = trans.invoke(auth_request, Zm::Client::AuthError)
    puts auth_resp
    # trans.context.token(auth_resp[:Body][:AuthResponse][:authToken].first[:_content])
    trans.context.token(auth_resp[:AuthResponse][:authToken].first[:_content])
    puts trans.context.to_hash

    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::GET_SERVER_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attribute('attrs', nil)
    server = Zm::Client::SoapElement.new('server', nil).add_attribute('by', 'name').add_content(@fixture_servers['servers'].first['name'])
    request.add_node(server)

    resp = trans.invoke(request)
    puts resp
    assert resp.is_a?(Hash)
  end

  def test_domain_invoke
    trans = Zm::Client::SoapAdminConnector.create(@config)
    auth_request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::AUTH_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    auth_request.add_attributes(name: @config.zimbra_admin_login, password: @config.zimbra_admin_password)
    auth_resp = trans.invoke(auth_request, Zm::Client::AuthError)
    puts auth_resp
    # trans.context.token(auth_resp[:Body][:AuthResponse][:authToken].first[:_content])
    trans.context.token(auth_resp[:AuthResponse][:authToken].first[:_content])
    puts trans.context.to_hash

    request = Zm::Client::SoapElement.new(Zm::Client::SoapAdminConstants::GET_DOMAIN_REQUEST, Zm::Client::SoapAdminConstants::NAMESPACE_STR)
    request.add_attribute('attrs', nil)
    domain = Zm::Client::SoapElement.new('domain', nil).add_attribute('by', 'name').add_content(@fixture_domains['domains'].first['name'])
    request.add_node(domain)

    trans.context.target_server(@fixture_servers['servers'][1]['id'])
    resp = trans.invoke(request)
    puts resp
    assert resp.is_a?(Hash)
  end
end
