# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'zm-ruby-client'
require_relative 'support/fake_zimbra'
require_relative 'support/fake_data'

Faraday.default_adapter = :fake_zimbra

module ZmTest
  class UnitTest < Minitest::Test
    ADMIN_LOGIN = 'admin@domain.tld'
    ADMIN_PASSWORD = 'secret'

    def setup
      @fake = FakeZimbra.current = FakeZimbra.new
    end

    def teardown
      FakeZimbra.current = nil
    end

    def build_config(**overrides)
      parameters = {
        zimbra_admin_url: 'https://zimbra.test:7071',
        zimbra_public_url: 'https://zimbra.test',
        zimbra_admin_login: ADMIN_LOGIN,
        zimbra_admin_password: ADMIN_PASSWORD
      }.merge(overrides)

      Zm::Client::ClusterConfig.new(parameters) do |config|
        config.log_path = File::NULL
      end
    end

    def logged_cluster
      @fake.on(:AuthRequest, FakeData.auth_response)
      Zm::Client::Cluster.new(build_config).tap(&:login)
    end

    def attr_nodes(body)
      [body[:a]].flatten.compact
    end

    def logged_account(name: 'user@domain.tld')
      account = logged_cluster.accounts.new
      account.name = name
      account.token = FakeData.token(admin: false)
      account
    end
  end
end
