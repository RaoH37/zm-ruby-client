# frozen_string_literal: true

require_relative 'integration_helper'

class PrefsIntegrationTest < ZmTest::IntegrationTest

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    prefs = @account.prefs.all
    assert prefs.is_a?(Hash)
  end
end
