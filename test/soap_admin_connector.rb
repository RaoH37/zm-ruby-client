# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../lib")

require './lib/zm/client'

class TestAccount < Minitest::Test
  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    @fixture_accounts = YAML.safe_load(File.read('./test/fixtures/accounts.yml'))
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
end
